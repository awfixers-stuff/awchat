defmodule Gateway.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    prepend_gleam_code_path()

    children = [
      Gateway.Repo,
      Gateway.ConnectionRegistry,
      Gateway.Scheduler,
      Gateway.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Gateway.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp prepend_gleam_code_path do
    gleam_ebin =
      Path.expand("../../../../packages/core/build/dev/erlang/relay_core/ebin", __DIR__)

    if File.exists?(gleam_ebin) do
      Code.prepend_path(gleam_ebin)
    end
  end
end