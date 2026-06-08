defmodule Broker.Route do
  @moduledoc false

  @auth_prefixes [
    "/v1/identities",
    "/v1/invites",
    "/v1/addresses",
    "/v1/connection-requests"
  ]

  @spec classify(Plug.Conn.t()) :: :ws | :auth | :relay | :not_found
  def classify(conn) do
    path = conn.request_path

    cond do
      websocket_upgrade?(conn) and ws_path?(path) ->
        :ws

      auth_path?(path) ->
        :auth

      String.starts_with?(path, "/v1/") ->
        :relay

      true ->
        :not_found
    end
  end

  @spec auth_path?(String.t()) :: boolean()
  def auth_path?(path) do
    Enum.any?(@auth_prefixes, &String.starts_with?(path, &1))
  end

  defp ws_path?(path), do: path in ["/v1/ws"] or String.starts_with?(path, "/v1/ws/")

  defp websocket_upgrade?(conn) do
    case Plug.Conn.get_req_header(conn, "upgrade") do
      [upgrade] -> String.downcase(upgrade) == "websocket"
      _ -> false
    end
  end
end