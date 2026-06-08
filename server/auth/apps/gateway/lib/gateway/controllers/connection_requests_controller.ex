defmodule Gateway.Controllers.ConnectionRequestsController do
  @moduledoc false
  import Gateway.Controllers.Helpers

  def index(conn, _params) do
    with {:ok, user_id} <- auth(conn, "GET", "/v1/connection-requests"),
         {:ok, body} <- Gateway.ConnectionRequests.list_pending(user_id) do
      json(conn, 200, body)
    else
      {:error, :unauthorized} -> error(conn, 401, "unauthorized")
    end
  end

  def update(conn, %{"id" => request_id}) do
    path = "/v1/connection-requests/#{request_id}"

    with {:ok, user_id} <- auth(conn, "PATCH", path),
         {:ok, body} <- Gateway.ConnectionRequests.respond(user_id, request_id, conn.body_params) do
      json(conn, 200, body)
    else
      {:error, :unauthorized} -> error(conn, 401, "unauthorized")
      {:error, :forbidden} -> error(conn, 403, "forbidden")
      {:error, :not_found} -> error(conn, 404, "not_found")
      {:error, _} -> error(conn, 400, "invalid_payload")
    end
  end

  defp auth(conn, method, path), do: Gateway.Auth.verify_rest(conn, method, path)
end