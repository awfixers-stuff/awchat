defmodule Gateway.ConnectionRegistry do
  @moduledoc """
  In-memory userId → WebSocket process map. Cleared on disconnect.
  """
  use GenServer

  @table :gateway_connections

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec register(String.t(), pid()) :: :ok
  def register(user_id, pid) when is_binary(user_id) do
    :ets.insert(@table, {user_id, pid, System.system_time(:millisecond)})
    :ok
  end

  @spec unregister(String.t()) :: :ok
  def unregister(user_id) when is_binary(user_id) do
    :ets.delete(@table, user_id)
    :ok
  end

  @spec lookup(String.t()) :: pid() | nil
  def lookup(user_id) when is_binary(user_id) do
    case :ets.lookup(@table, user_id) do
      [{^user_id, pid, _}] -> pid
      [] -> nil
    end
  end

  @spec connected_user_ids() :: [String.t()]
  def connected_user_ids do
    :ets.tab2list(@table)
    |> Enum.map(fn {user_id, _pid, _} -> user_id end)
  end

  @spec count() :: non_neg_integer()
  def count, do: :ets.info(@table, :size)

  @impl true
  def init(_opts) do
    :ets.new(@table, [:named_table, :set, :protected, read_concurrency: true])
    {:ok, %{}}
  end
end