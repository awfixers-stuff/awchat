defmodule Gateway.Endpoint do
  @moduledoc false
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    port = Application.get_env(:gateway, Gateway.Endpoint)[:port] || 8081

    children = [
      {Bandit, plug: Gateway.Router, port: port, scheme: :http}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end