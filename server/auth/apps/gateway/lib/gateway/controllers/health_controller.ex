defmodule Gateway.Controllers.HealthController do
  @moduledoc false
  import Plug.Conn

  def health(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{"status" => "ok"}))
  end

  def ready(conn, _params) do
    case Gateway.Repo.query("SELECT 1") do
      {:ok, _} ->
        version =
          case Gateway.Repo.query("SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 1") do
            {:ok, %{rows: [[v]]}} -> v
            _ -> nil
          end

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(%{"status" => "ready", "migration" => version}))

      {:error, reason} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(503, Jason.encode!(%{"status" => "not_ready", "reason" => inspect(reason)}))
    end
  end
end