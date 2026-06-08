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

  post "/v1/identities" do
    conn = parse_json(conn)
    Gateway.Controllers.IdentitiesController.create(conn, %{})
  end

  post "/v1/invites" do
    conn = parse_json(conn)
    Gateway.Controllers.InvitesController.create(conn, %{})
  end

  get "/v1/invites/:token" do
    Gateway.Controllers.InvitesController.show(conn, conn.path_params)
  end

  post "/v1/invites/:token/requests" do
    conn = parse_json(conn)
    Gateway.Controllers.InvitesController.create_request(conn, conn.path_params)
  end

  post "/v1/addresses" do
    conn = parse_json(conn)
    Gateway.Controllers.AddressesController.create(conn, %{})
  end

  get "/v1/addresses/:token" do
    Gateway.Controllers.AddressesController.show(conn, conn.path_params)
  end

  delete "/v1/addresses/:token" do
    Gateway.Controllers.AddressesController.delete(conn, conn.path_params)
  end

  post "/v1/addresses/:token/requests" do
    conn = parse_json(conn)
    Gateway.Controllers.AddressesController.create_request(conn, conn.path_params)
  end

  get "/v1/connection-requests" do
    Gateway.Controllers.ConnectionRequestsController.index(conn, %{})
  end

  patch "/v1/connection-requests/:id" do
    conn = parse_json(conn)
    Gateway.Controllers.ConnectionRequestsController.update(conn, conn.path_params)
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