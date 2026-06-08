defmodule Gateway.Controllers.HealthController do
  @moduledoc false
  import Plug.Conn

  def health(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{"status" => "ok"}))
  end

  def ready(conn, _params) do
    with :ok <- check_postgres(),
         :ok <- check_redis() do
      version =
        case Gateway.Repo.query("SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 1") do
          {:ok, %{rows: [[v]]}} -> v
          _ -> nil
        end

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(%{"status" => "ready", "migration" => version}))
    else
      {:error, reason} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(503, Jason.encode!(%{"status" => "not_ready", "reason" => inspect(reason)}))
    end
  end

  defp check_postgres do
    case Gateway.Repo.query("SELECT 1") do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, {:postgres, reason}}
    end
  end

  defp check_redis do
    if Gateway.Redis.enabled?() do
      case Gateway.Redis.ping() do
        :ok -> :ok
        {:error, reason} -> {:error, {:redis, reason}}
      end
    else
      :ok
    end
  end
end