defmodule Gateway.Time do
  @spec now() :: DateTime.t()
  def now, do: DateTime.utc_now()

  @spec iso8601(DateTime.t()) :: String.t()
  def iso8601(%DateTime{} = dt), do: DateTime.to_iso8601(dt)

  @spec unix(DateTime.t()) :: integer()
  def unix(%DateTime{} = dt), do: DateTime.to_unix(dt)

  @spec parse_iso8601(String.t()) :: {:ok, DateTime.t()} | {:error, atom()}
  def parse_iso8601(value) when is_binary(value) do
    case DateTime.from_iso8601(value) do
      {:ok, dt, _offset} -> {:ok, DateTime.truncate(dt, :second)}
      error -> error
    end
  end

  @spec within_replay_window?(DateTime.t()) :: boolean()
  def within_replay_window?(%DateTime{} = timestamp) do
    diff = DateTime.diff(now(), timestamp, :second) |> Kernel.abs()
    diff <= Gateway.RelayCore.replay_window_seconds()
  end

  def add_hours(%DateTime{} = dt, hours) do
    DateTime.add(dt, hours * 3600, :second)
  end
end