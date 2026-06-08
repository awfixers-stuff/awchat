defmodule Gateway.Router do
  @moduledoc false
  use Plug.Router

  plug :match
  plug :dispatch

  get "/v1/health" do
    Gateway.Controllers.HealthController.health(conn, %{})
  end

  get "/v1/ready" do
    Gateway.Controllers.HealthController.ready(conn, %{})
  end

  post "/v1/register" do
    conn = parse_json(conn)
    Gateway.Controllers.RegisterController.create(conn, %{})
  end

  get "/v1/prekeys/:user_id" do
    Gateway.Controllers.PrekeysController.show(conn, conn.path_params)
  end

  post "/v1/chats" do
    conn = parse_json(conn)
    Gateway.Controllers.ChatsController.create(conn, %{})
  end

  get "/v1/chats/:chat_id" do
    Gateway.Controllers.ChatsController.show(conn, conn.path_params)
  end

  patch "/v1/chats/:chat_id/members" do
    conn = parse_json(conn)
    Gateway.Controllers.ChatsController.update_members(conn, conn.path_params)
  end

  post "/v1/purge" do
    conn = parse_json(conn)
    Gateway.Controllers.PurgeController.create(conn, %{})
  end

  get "/v1/ws" do
    conn
    |> WebSockAdapter.upgrade(Gateway.WebSocketHandler, %{}, [])
    |> halt()
  end

  match _ do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, Jason.encode!(%{"error" => "not_found"}))
  end

  defp parse_json(conn) do
    conn
    |> Gateway.Plugs.RawBody.call([])
    |> Gateway.Plugs.JsonParser.call([])
  end
end