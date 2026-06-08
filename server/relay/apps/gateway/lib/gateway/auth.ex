defmodule Gateway.Auth do
  @moduledoc false
  alias Gateway.Native.Crypto
  alias Gateway.Repo
  alias Gateway.Schemas.{AuthNonce, User}

  @user_id_header "x-awchat-user-id"
  @timestamp_header "x-awchat-timestamp"
  @signature_header "x-awchat-signature"

  @spec verify_rest(Plug.Conn.t(), String.t(), String.t()) ::
          {:ok, String.t()} | {:error, atom()}
  def verify_rest(conn, method, path) do
    with {:ok, user_id} <- header(conn, @user_id_header),
         true <- Gateway.RelayCore.valid_user_id?(user_id),
         {:ok, timestamp} <- header(conn, @timestamp_header),
         {:ok, parsed_time} <- Gateway.Time.parse_iso8601(timestamp),
         true <- Gateway.Time.within_replay_window?(parsed_time),
         {:ok, signature} <- header(conn, @signature_header),
         {:ok, identity_key} <- fetch_identity_key(user_id),
         true <-
           Crypto.verify_rest_signature(
             identity_key,
             method,
             path,
             conn.body_params |> body_bytes(conn),
             timestamp,
             user_id,
             signature
           ) do
      {:ok, user_id}
    else
      false -> {:error, :invalid_signature}
      {:error, reason} -> {:error, reason}
      _ -> {:error, :unauthorized}
    end
  end

  @spec issue_ws_challenge() :: map()
  def issue_ws_challenge do
    nonce = :crypto.strong_rand_bytes(32)
    server_time = Gateway.Time.now() |> Gateway.Time.iso8601()

    expires_at =
      Gateway.Time.now()
      |> DateTime.add(Gateway.RelayCore.auth_nonce_ttl_seconds(), :second)

    %AuthNonce{}
    |> Ecto.Changeset.change(%{
      nonce: nonce,
      created_at: Gateway.Time.now(),
      expires_at: expires_at
    })
    |> Repo.insert!(on_conflict: :nothing)

    %{
      "type" => "auth_challenge",
      "nonce" => Base.encode64(nonce),
      "serverTime" => server_time,
      "ttlSec" => Gateway.RelayCore.auth_nonce_ttl_seconds()
    }
  end

  @spec verify_ws_response(map()) :: {:ok, String.t(), String.t()} | {:error, atom()}
  def verify_ws_response(%{
        "userId" => user_id,
        "nonce" => nonce_b64,
        "serverTime" => server_time,
        "signature" => signature
      }) do
    with true <- Gateway.RelayCore.valid_user_id?(user_id),
         {:ok, parsed_time} <- Gateway.Time.parse_iso8601(server_time),
         true <- Gateway.Time.within_replay_window?(parsed_time),
         {:ok, nonce} <- decode_nonce(nonce_b64),
         :ok <- consume_nonce(nonce),
         {:ok, identity_key} <- fetch_identity_key(user_id),
         true <- Crypto.verify_ws_signature(identity_key, nonce_b64, user_id, server_time, signature) do
      {:ok, user_id, connection_id()}
    else
      {:error, :nonce_expired} -> {:error, :nonce_expired}
      false -> {:error, :invalid_signature}
      {:error, reason} -> {:error, reason}
      _ -> {:error, :unauthorized}
    end
  end

  def verify_ws_response(_), do: {:error, :invalid_frame}

  defp consume_nonce(nonce) do
    now = Gateway.Time.now()

    case Repo.get(AuthNonce, nonce) do
      nil ->
        {:error, :nonce_expired}

      %AuthNonce{expires_at: expires_at} ->
        if DateTime.compare(expires_at, now) == :gt do
          Repo.delete!(%AuthNonce{nonce: nonce})
          :ok
        else
          Repo.delete(%AuthNonce{nonce: nonce})
          {:error, :nonce_expired}
        end
    end
  end

  defp fetch_identity_key(user_id) do
    case Repo.get(User, user_id) do
      %User{identity_key: key} when is_binary(key) -> {:ok, key}
      _ -> {:error, :unknown_user}
    end
  end

  defp decode_nonce(nonce_b64) do
    case Base.decode64(nonce_b64) do
      {:ok, <<_::binary-size(32)>> = nonce} -> {:ok, nonce}
      _ -> {:error, :invalid_nonce}
    end
  end

  defp connection_id do
    "conn_" <> Base.encode16(:crypto.strong_rand_bytes(8), case: :lower)
  end

  defp header(conn, name) do
    case Plug.Conn.get_req_header(conn, name) do
      [value | _] -> {:ok, value}
      [] -> {:error, :missing_header}
    end
  end

  defp body_bytes(_body_params, conn) do
    case conn.assigns[:raw_body] do
      body when is_binary(body) -> body
      _ -> ""
    end
  end
end