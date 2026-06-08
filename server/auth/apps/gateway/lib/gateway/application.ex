defmodule Gateway.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Gateway.Repo,
      Gateway.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Gateway.Supervisor]
    Supervisor.start_link(children, opts)
  end
end