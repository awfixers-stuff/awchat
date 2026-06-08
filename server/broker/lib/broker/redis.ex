defmodule Broker.Redis do
  @moduledoc false
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec enabled?() :: boolean()
  def enabled?, do: is_binary(url()) and url() != ""

  @spec url() :: String.t() | nil
  def url, do: Application.get_env(:broker, :redis_url)

  @spec command(term()) :: {:ok, term()} | {:error, term()}
  def command(cmd) do
    Redix.command(pool_name(), cmd)
  end

  @spec ping() :: :ok | {:error, term()}
  def ping do
    case command(["PING"]) do
      {:ok, "PONG"} -> :ok
      {:ok, other} -> {:error, {:unexpected_pong, other}}
      {:error, reason} -> {:error, reason}
    end
  end

  defp pool_name, do: :broker_redis

  @impl true
  def init(_opts) do
    if enabled?() do
      children = [{Redix, {url(), [name: pool_name()]}}]
      Supervisor.init(children, strategy: :one_for_one)
    else
      Supervisor.init([], strategy: :one_for_one)
    end
  end
end