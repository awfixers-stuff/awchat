defmodule Broker.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    port = Application.get_env(:broker, :port)

    children =
      [
        Broker.Redis,
        {Broker.RateLimiter.Ets, [clean_period: :timer.minutes(1)]},
        {Bandit, plug: Broker.Router, port: port, scheme: :http}
      ]
      |> Enum.reject(fn
        {Broker.RateLimiter.Ets, _} -> Broker.Redis.enabled?()
        _ -> false
      end)

    Supervisor.start_link(children, strategy: :one_for_one, name: Broker.Supervisor)
  end
end