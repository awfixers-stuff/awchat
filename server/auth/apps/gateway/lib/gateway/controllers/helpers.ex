defmodule Gateway.Controllers.Helpers do
  @moduledoc false
  import Plug.Conn

  def json(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
  end

  def error(conn, status, code) do
    json(conn, status, %{"error" => code})
  end

  def auth_error(conn, {:error, _}), do: error(conn, 401, "unauthorized")
end