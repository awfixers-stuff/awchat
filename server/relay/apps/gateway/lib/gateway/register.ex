defmodule Gateway.Register do
  @moduledoc false
  alias Gateway.Native.Crypto
  alias Gateway.Repo
  alias Gateway.Schemas.{KyberPrekey, Prekey, SignedPrekey, User}

  @spec register(map()) :: {:ok, map()} | {:error, atom()}
  def register(params) do
    with {:ok, user_id} <- fetch_user_id(params),
         true <- Gateway.RelayCore.valid_user_id?(user_id),
         {:ok, identity_key} <- decode_b64(params, "identityKey"),
         true <- Crypto.verify_identity_key(identity_key),
         {:ok, signed} <- decode_prekey(params, "signedPreKey"),
         {:ok, kyber} <- decode_prekey(params, "kyberPreKey"),
         {:ok, one_time_keys} <- decode_one_time_prekeys(params) do
      now = Gateway.Time.now()

      Repo.transaction(fn ->
        upsert_user!(user_id, identity_key, Map.get(params, "registrationId", 0), now)
        upsert_signed_prekey!(user_id, signed, now)
        upsert_kyber_prekey!(user_id, kyber, now)
        replace_one_time_prekeys!(user_id, one_time_keys, now)
      end)

      {:ok, %{"userId" => user_id}}
    else
      false -> {:error, :invalid_user_id}
      {:error, reason} -> {:error, reason}
    end
  end

  defp fetch_user_id(%{"userId" => user_id}), do: {:ok, user_id}
  defp fetch_user_id(_), do: {:error, :invalid_payload}

  defp decode_b64(params, field) do
    case Map.get(params, field) do
      value when is_binary(value) ->
        case Base.decode64(value) do
          {:ok, bin} -> {:ok, bin}
          :error -> {:error, :invalid_base64}
        end

      _ ->
        {:error, :invalid_payload}
    end
  end

  defp decode_prekey(params, field) do
    case Map.get(params, field) do
      %{"keyId" => key_id, "publicKey" => public_key, "signature" => signature}
      when is_integer(key_id) ->
        with {:ok, pub} <- Base.decode64(public_key),
             {:ok, sig} <- Base.decode64(signature) do
          {:ok, %{key_id: key_id, public_key: pub, signature: sig}}
        else
          :error -> {:error, :invalid_base64}
        end

      _ ->
        {:error, :invalid_payload}
    end
  end

  defp decode_one_time_prekeys(%{"oneTimePreKeys" => keys}) when is_list(keys) do
    keys
    |> Enum.reduce_while({:ok, []}, fn item, {:ok, acc} ->
      case item do
        %{"keyId" => key_id, "publicKey" => public_key} when is_integer(key_id) ->
          case Base.decode64(public_key) do
            {:ok, pub} -> {:cont, {:ok, [%{key_id: key_id, public_key: pub} | acc]}}
            :error -> {:halt, {:error, :invalid_base64}}
          end

        _ ->
          {:halt, {:error, :invalid_payload}}
      end
    end)
    |> case do
      {:ok, list} -> {:ok, Enum.reverse(list)}
      error -> error
    end
  end

  defp decode_one_time_prekeys(_), do: {:error, :invalid_payload}

  defp upsert_user!(user_id, identity_key, registration_id, now) do
    %User{}
    |> Ecto.Changeset.change(%{
      id: user_id,
      identity_key: identity_key,
      registration_id: registration_id,
      created_at: now
    })
    |> Repo.insert!(
      on_conflict: {:replace, [:identity_key, :registration_id]},
      conflict_target: :id
    )
  end

  defp upsert_signed_prekey!(user_id, signed, now) do
    %SignedPrekey{}
    |> Ecto.Changeset.change(%{
      user_id: user_id,
      key_id: signed.key_id,
      public_key: signed.public_key,
      signature: signed.signature,
      created_at: now
    })
    |> Repo.insert!(
      on_conflict: {:replace, [:key_id, :public_key, :signature, :created_at]},
      conflict_target: :user_id
    )
  end

  defp upsert_kyber_prekey!(user_id, kyber, now) do
    %KyberPrekey{}
    |> Ecto.Changeset.change(%{
      user_id: user_id,
      key_id: kyber.key_id,
      public_key: kyber.public_key,
      signature: kyber.signature,
      created_at: now
    })
    |> Repo.insert!(
      on_conflict: {:replace, [:key_id, :public_key, :signature, :created_at]},
      conflict_target: :user_id
    )
  end

  defp replace_one_time_prekeys!(user_id, keys, now) do
    import Ecto.Query

    from(p in Prekey, where: p.user_id == ^user_id and p.consumed == false)
    |> Repo.delete_all()

    Enum.each(keys, fn key ->
      %Prekey{}
      |> Ecto.Changeset.change(%{
        user_id: user_id,
        key_id: key.key_id,
        public_key: key.public_key,
        consumed: false,
        inserted_at: now
      })
      |> Repo.insert!()
    end)
  end
end