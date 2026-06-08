defmodule Broker.Security do
  @moduledoc false
  import Plug.Conn

  @behaviour Plug

  @mutating_methods ~w(POST PUT PATCH DELETE)

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> validate_path()
    |> validate_body_size()
    |> validate_content_type()
    |> put_security_headers()
  end

  defp validate_path(%{request_path: path} = conn) when path in ["/health", "/ops/status"] do
    conn
  end

  defp validate_path(%{request_path: path} = conn) do
    if String.starts_with?(path, "/v1/") do
      conn
    else
      conn |> send_resp(404, "not found") |> halt()
    end
  end

  defp validate_body_size(conn) do
    max = Broker.Config.max_body_bytes()

    case get_req_header(conn, "content-length") do
      [length] ->
        case Integer.parse(length) do
          {size, ""} when size > max ->
            rate_limited(conn, 413, "payload_too_large", "Request body too large")

          _ ->
            conn
        end

      _ ->
        conn
    end
  end

  defp validate_content_type(%{method: method} = conn) when method in @mutating_methods do
    if mutating_body?(conn) do
      case get_req_header(conn, "content-type") do
        [type | _] ->
          if String.starts_with?(String.downcase(type), "application/json") do
            conn
          else
            conn |> send_resp(415, Jason.encode!(%{code: "unsupported_media_type"})) |> halt()
          end

        [] ->
          conn |> send_resp(415, Jason.encode!(%{code: "unsupported_media_type"})) |> halt()
      end
    else
      conn
    end
  end

  defp validate_content_type(conn), do: conn

  defp mutating_body?(conn) do
    case get_req_header(conn, "content-length") do
      [length] ->
        case Integer.parse(length) do
          {size, ""} -> size > 0
          _ -> false
        end

      _ ->
        false
    end
  end

  defp put_security_headers(conn) do
    conn
    |> put_resp_header("strict-transport-security", "max-age=31536000; includeSubDomains; preload")
    |> put_resp_header("x-content-type-options", "nosniff")
    |> put_resp_header("x-frame-options", "DENY")
    |> put_resp_header("referrer-policy", "strict-origin-when-cross-origin")
    |> put_resp_header(
      "permissions-policy",
      "camera=(), microphone=(), geolocation=()"
    )
    |> delete_resp_header("server")
  end

  defp rate_limited(conn, status, code, message) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(%{code: code, message: message}))
    |> halt()
  end
end