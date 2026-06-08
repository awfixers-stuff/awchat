defmodule Gateway.Auth do
  @moduledoc false
  alias Gateway.Native.Crypto
  alias Gateway.Repo
  alias Gateway.Schemas.Identity

  @user_id_header "x-awchat-user-id"
  @timestamp_header "x-awchat-timestamp"
  @signature_header "x-awchat-signature"

  @spec verify_rest(Plug.Conn.t(), String.t(), String.t()) ::
          {:ok, String.t()} | {:error, atom()}
  def verify_rest(conn, method, path) do
    with {:ok, user_id} <- header(conn, @user_id_header),
         true <- Gateway.AuthCore.valid_user_id?(user_id),
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
      false -> {:error, :unauthorized}
      {:error, :invalid_signature} -> {:error, :unauthorized}
      {:error, :missing_header} -> {:error, :unauthorized}
      {:error, :unknown_user} -> {:error, :unauthorized}
      {:error, reason} -> {:error, reason}
      _ -> {:error, :unauthorized}
    end
  end

  defp fetch_identity_key(user_id) do
    case Repo.get(Identity, user_id) do
      %Identity{identity_key: key} when is_binary(key) -> {:ok, key}
      _ -> {:error, :unknown_user}
    end
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