defmodule Gateway.Controllers.InvitesController do
  @moduledoc false
  import Gateway.Controllers.Helpers

  def create(conn, _params) do
    with {:ok, user_id} <- auth(conn, "POST", "/v1/invites"),
         {:ok, body} <- Gateway.Invites.create(user_id, conn.body_params) do
      json(conn, 201, body)
    else
      {:error, :unauthorized} -> error(conn, 401, "unauthorized")
      {:error, _} -> error(conn, 400, "invalid_payload")
    end
  end

  def show(conn, %{"token" => token}) do
    case Gateway.Invites.resolve(token) do
      {:ok, body} -> json(conn, 200, body)
      {:error, :consumed} -> error(conn, 410, "consumed")
      {:error, :not_found} -> error(conn, 404, "not_found")
    end
  end

  def create_request(conn, %{"token" => token}) do
    path = "/v1/invites/#{token}/requests"

    with {:ok, user_id} <- auth(conn, "POST", path),
         {:ok, body} <- Gateway.Invites.submit_request(token, user_id, conn.body_params) do
      json(conn, 201, body)
    else
      {:error, :unauthorized} -> error(conn, 401, "unauthorized")
      {:error, :consumed} -> error(conn, 410, "consumed")
      {:error, :self_request} -> error(conn, 400, "self_request")
      {:error, :not_found} -> error(conn, 404, "not_found")
      {:error, _} -> error(conn, 400, "invalid_payload")
    end
  end

  defp auth(conn, method, path), do: Gateway.Auth.verify_rest(conn, method, path)
end