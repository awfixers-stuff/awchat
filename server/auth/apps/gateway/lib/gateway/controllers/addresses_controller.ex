defmodule Gateway.Controllers.AddressesController do
  @moduledoc false
  import Plug.Conn
  import Gateway.Controllers.Helpers

  def create(conn, _params) do
    with {:ok, user_id} <- auth(conn, "POST", "/v1/addresses"),
         {:ok, body} <- Gateway.Addresses.create(user_id, conn.body_params) do
      json(conn, 201, body)
    else
      {:error, :unauthorized} -> error(conn, 401, "unauthorized")
      {:error, _} -> error(conn, 400, "invalid_payload")
    end
  end

  def show(conn, %{"token" => token}) do
    case Gateway.Addresses.resolve(token) do
      {:ok, body} -> json(conn, 200, body)
      {:error, :revoked} -> error(conn, 410, "revoked")
      {:error, :not_found} -> error(conn, 404, "not_found")
    end
  end

  def delete(conn, %{"token" => token}) do
    path = "/v1/addresses/#{token}"

    with {:ok, user_id} <- auth(conn, "DELETE", path),
         :ok <- Gateway.Addresses.revoke(token, user_id) do
      send_resp(conn, 204, "")
    else
      {:error, :unauthorized} -> error(conn, 401, "unauthorized")
      {:error, :forbidden} -> error(conn, 403, "forbidden")
      {:error, :not_found} -> error(conn, 404, "not_found")
    end
  end

  def create_request(conn, %{"token" => token}) do
    path = "/v1/addresses/#{token}/requests"

    with {:ok, user_id} <- auth(conn, "POST", path),
         {:ok, body} <- Gateway.Addresses.submit_request(token, user_id, conn.body_params) do
      json(conn, 201, body)
    else
      {:error, :unauthorized} -> error(conn, 401, "unauthorized")
      {:error, :revoked} -> error(conn, 410, "revoked")
      {:error, :self_request} -> error(conn, 400, "self_request")
      {:error, :not_found} -> error(conn, 404, "not_found")
      {:error, _} -> error(conn, 400, "invalid_payload")
    end
  end

  defp auth(conn, method, path), do: Gateway.Auth.verify_rest(conn, method, path)
end