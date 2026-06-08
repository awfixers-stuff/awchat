defmodule Gateway.Prekeys do
  @moduledoc false
  import Ecto.Query

  alias Gateway.Repo
  alias Gateway.Schemas.{KyberPrekey, Prekey, SignedPrekey, User}

  @spec fetch_bundle(String.t()) :: {:ok, map()} | {:error, atom()}
  def fetch_bundle(user_id) do
    with true <- Gateway.RelayCore.valid_user_id?(user_id),
         %User{} = user <- Repo.get(User, user_id),
         %SignedPrekey{} = signed <- Repo.get(SignedPrekey, user_id),
         %KyberPrekey{} = kyber <- Repo.get(KyberPrekey, user_id),
         {:ok, one_time} <- fetch_one_time_prekey(user_id) do
      {:ok,
       %{
         "userId" => user_id,
         "registrationId" => user.registration_id,
         "deviceId" => 1,
         "identityKey" => Base.encode64(user.identity_key),
         "signedPreKey" => encode_prekey(signed.key_id, signed.public_key, signed.signature),
         "kyberPreKey" => encode_prekey(kyber.key_id, kyber.public_key, kyber.signature),
         "oneTimePreKey" => encode_one_time(one_time)
       }}
    else
      false -> {:error, :invalid_user_id}
      nil -> {:error, :not_found}
      {:error, reason} -> {:error, reason}
    end
  end

  defp fetch_one_time_prekey(user_id) do
    one_time =
      from(p in Prekey,
        where: p.user_id == ^user_id and p.consumed == false,
        order_by: [asc: p.inserted_at],
        limit: 1
      )
      |> Repo.one()

    case one_time do
      nil ->
        {:ok, nil}

      %Prekey{} = prekey ->
        Repo.delete!(prekey)
        {:ok, prekey}
    end
  end

  defp encode_prekey(key_id, public_key, signature) do
    %{
      "keyId" => key_id,
      "publicKey" => Base.encode64(public_key),
      "signature" => Base.encode64(signature)
    }
  end

  defp encode_one_time(nil), do: nil

  defp encode_one_time(%Prekey{key_id: key_id, public_key: public_key}) do
    %{
      "keyId" => key_id,
      "publicKey" => Base.encode64(public_key)
    }
  end
end