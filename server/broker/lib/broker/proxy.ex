defmodule Broker.Proxy do
  @moduledoc false

  @client_options [receive_timeout: 30_000]

  @spec http(Plug.Conn.t(), :auth | :relay) :: Plug.Conn.t()
  def http(conn, target) do
    upstream =
      case target do
        :auth -> Broker.Config.auth_http_url()
        :relay -> Broker.Config.relay_http_url()
      end

    opts =
      ReverseProxyPlug.init(
        upstream: upstream,
        client: ReverseProxyPlug.HTTPClient.Adapters.Req,
        client_options: @client_options,
        preserve_host_header: false
      )

    ReverseProxyPlug.call(conn, opts)
  end

  @spec websocket(Plug.Conn.t()) :: Plug.Conn.t()
  def websocket(conn) do
    ReverseProxyPlugWebsocket.call(conn, [
      upstream_uri: Broker.Config.relay_ws_url() <> conn.request_path,
      path: conn.request_path,
      connect_timeout: 10_000,
      upgrade_timeout: 15_000
    ])
  end
end