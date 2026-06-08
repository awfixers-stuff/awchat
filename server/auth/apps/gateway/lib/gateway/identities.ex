defmodule Gateway.Identities do
  @moduledoc false
  alias Gateway.Native.Crypto
  alias Gateway.Repo
  alias Gateway.Schemas.Identity

  @spec register(map()) :: {:ok, map()} | {:error, atom()}
  def register(params) do
    with {:ok, user_id} <- fetch_user_id(params),
         true <- Gateway.AuthCore.valid_user_id?(user_id),
         {:ok, identity_key} <- decode_b64(params, "identityKey"),
         {:ok, identity_key_b64} <- fetch_identity_key_b64(params),
         {:ok, proof_signature} <- fetch_proof_signature(params),
         true <- Crypto.verify_identity_key(identity_key),
         :ok <- verify_user_id_matches_key(user_id, identity_key),
         true <-
           Crypto.verify_registration_proof(
             identity_key,
             user_id,
             identity_key_b64,
             proof_signature
           ) do
      now = Gateway.Time.now()

      %Identity{}
      |> Ecto.Changeset.change(%{
        id: user_id,
        identity_key: identity_key,
        created_at: now
      })
      |> Repo.insert(
        on_conflict: {:replace, [:identity_key]},
        conflict_target: :id,
        returning: true
      )
      |> case do
        {:ok, _} -> {:ok, %{"userId" => user_id}}
        {:error, _} -> {:error, :invalid_payload}
      end
    else
      {:error, :invalid_user_id} -> {:error, :invalid_user_id}
      false -> {:error, :invalid_proof}
      {:error, reason} -> {:error, reason}
    end
  end

  defp fetch_user_id(%{"userId" => user_id}), do: {:ok, user_id}
  defp fetch_user_id(_), do: {:error, :invalid_payload}

  defp fetch_identity_key_b64(%{"identityKey" => key}) when is_binary(key), do: {:ok, key}
  defp fetch_identity_key_b64(_), do: {:error, :invalid_payload}

  defp fetch_proof_signature(%{"proofSignature" => sig}) when is_binary(sig), do: {:ok, sig}
  defp fetch_proof_signature(_), do: {:error, :invalid_payload}

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

  defp verify_user_id_matches_key(user_id, identity_key) do
    if derive_user_id(identity_key) == user_id, do: :ok, else: {:error, :invalid_user_id}
  end

  defp derive_user_id(identity_key) do
    fingerprint = :crypto.hash(:sha256, identity_key)
    Gateway.AuthCore.user_id_prefix() <> Gateway.Base32.encode(fingerprint)
  end
end