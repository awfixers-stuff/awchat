defmodule Broker.Ops do
  @moduledoc false
  import Plug.Conn

  @spec status(Plug.Conn.t()) :: Plug.Conn.t()
  def status(conn) do
    case verify_token(conn) do
      :ok ->
        body =
          %{
            broker: %{status: "ok"},
            auth: probe_service(Broker.Config.auth_http_url()),
            relay: probe_service(Broker.Config.relay_http_url())
          }
          |> Jason.encode!()

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, body)

      :unauthorized ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Jason.encode!(%{code: "unauthorized", message: "Invalid ops token"}))
    end
  end

  defp verify_token(conn) do
    expected = Broker.Config.ops_token()

    case get_req_header(conn, "x-ops-token") do
      [token] when is_binary(expected) and token == expected -> :ok
      _ -> :unauthorized
    end
  end

  defp probe_service(base_url) do
    %{
      health: probe_endpoint(base_url <> "/v1/health"),
      ready: probe_endpoint(base_url <> "/v1/ready")
    }
  end

  defp probe_endpoint(url) do
    started = System.monotonic_time(:millisecond)

    case Req.get(url, retry: false, receive_timeout: 5_000, connect_options: [timeout: 5_000]) do
      {:ok, %{status: status, body: body}} ->
        %{
          status: status,
          ok: status in 200..299,
          latency_ms: System.monotonic_time(:millisecond) - started,
          body: summarize_body(body)
        }

      {:error, reason} ->
        %{
          status: nil,
          ok: false,
          latency_ms: System.monotonic_time(:millisecond) - started,
          error: inspect(reason)
        }
    end
  end

  defp summarize_body(body) when is_map(body), do: Jason.encode!(body)
  defp summarize_body(body) when is_binary(body) and byte_size(body) <= 512, do: body
  defp summarize_body(body) when is_binary(body), do: String.slice(body, 0, 512) <> "…"
  defp summarize_body(body), do: inspect(body)
end