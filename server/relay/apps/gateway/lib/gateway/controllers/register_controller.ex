defmodule Gateway.Controllers.RegisterController do
  @moduledoc false
  import Plug.Conn

  def create(conn, _params) do
    case Gateway.Register.register(conn.body_params) do
      {:ok, body} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(201, Jason.encode!(body))

      {:error, :invalid_user_id} ->
        error(conn, 400, "invalid_user_id")

      {:error, _} ->
        error(conn, 400, "invalid_payload")
    end
  end

  defp error(conn, status, code) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(%{"error" => code}))
  end
end