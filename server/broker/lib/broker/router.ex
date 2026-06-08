defmodule Broker.Router do
  @moduledoc false
  use Plug.Router

  plug Plug.RequestId
  plug Plug.Logger
  plug Broker.Security
  plug Broker.RateLimit
  plug :match
  plug :dispatch

  get "/health" do
    send_resp(conn, 200, "ok")
  end

  get "/ops/status" do
    Broker.Ops.status(conn)
  end

  match _ do
    case Broker.Route.classify(conn) do
      :ws ->
        Broker.Proxy.websocket(conn)

      :auth ->
        Broker.Proxy.http(conn, :auth)

      :relay ->
        Broker.Proxy.http(conn, :relay)

      :not_found ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(404, "not found")
    end
  end
end