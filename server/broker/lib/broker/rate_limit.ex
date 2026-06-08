defmodule Broker.RateLimit do
  @moduledoc false
  import Plug.Conn

  @behaviour Plug

  @mutating_methods ~w(POST PUT PATCH DELETE)

  def init(opts), do: opts

  def call(%{request_path: path} = conn, _opts) when path in ["/health", "/ops/status"] do
    conn
  end

  def call(%{request_path: path} = conn, _opts) do
    if String.starts_with?(path, "/v1/") do
      conn
      |> check_ip_limit()
      |> check_user_limit()
    else
      conn
    end
  end

  defp check_ip_limit(conn) do
    key = "ip:" <> client_ip(conn)
    window = Broker.Config.rate_limit_window_ms()
    limit = Broker.Config.ip_rate_limit()

    case Broker.RateLimiter.hit(key, window, limit) do
      {:allow, _count} ->
        conn

      {:deny, _retry_after} ->
        deny(conn)
    end
  end

  defp check_user_limit(%{method: method} = conn) when method in @mutating_methods do
    case Plug.Conn.get_req_header(conn, "x-awchat-user-id") do
      [user_id] when is_binary(user_id) and user_id != "" ->
        key = "user:" <> user_id
        window = Broker.Config.rate_limit_window_ms()
        limit = Broker.Config.user_rate_limit()

        case Broker.RateLimiter.hit(key, window, limit) do
          {:allow, _count} ->
            conn

          {:deny, _retry_after} ->
            deny(conn)
        end

      _ ->
        conn
    end
  end

  defp check_user_limit(conn), do: conn

  defp deny(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(429, Jason.encode!(%{code: "rate_limited", message: "Too many requests"}))
    |> halt()
  end

  defp client_ip(conn) do
    case Plug.Conn.get_req_header(conn, "x-forwarded-for") do
      [forwarded | _] ->
        forwarded |> String.split(",", parts: 2) |> List.first() |> String.trim()

      _ ->
        conn.remote_ip |> :inet.ntoa() |> to_string()
    end
  end
end