defmodule Gateway.Controllers.PrekeysController do
  @moduledoc false
  import Plug.Conn

  def show(conn, %{"user_id" => user_id}) do
    case Gateway.Prekeys.fetch_bundle(user_id) do
      {:ok, body} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(body))

      {:error, :not_found} ->
        error(conn, 404, "not_found")

      {:error, _} ->
        error(conn, 400, "invalid_request")
    end
  end

  defp error(conn, status, code) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(%{"error" => code}))
  end
end