defmodule Gateway.Controllers.PurgeController do
  @moduledoc false
  import Plug.Conn

  def create(conn, _params) do
    with {:ok, caller_id} <- Gateway.Auth.verify_rest(conn, "POST", "/v1/purge"),
         {:ok, body} <- Gateway.Purge.purge_message(caller_id, conn.body_params) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(body))
    else
      {:error, :unauthorized} -> error(conn, 401, "unauthorized")
      {:error, :forbidden} -> error(conn, 403, "forbidden")
      {:error, _} -> error(conn, 400, "invalid_payload")
    end
  end

  defp error(conn, status, code) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(%{"error" => code}))
  end
end