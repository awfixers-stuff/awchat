defmodule Broker.MixProject do
  use Mix.Project

  def project do
    [
      app: :broker,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      releases: releases(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {Broker.Application, []}
    ]
  end

  defp releases do
    [
      broker: [
        include_executables_for: [:unix],
        applications: [runtime_tools: :permanent]
      ]
    ]
  end

  defp deps do
    [
      {:bandit, "~> 1.6"},
      {:gun, "~> 2.1"},
      {:hammer, "~> 7.0"},
      {:redix, "~> 1.5"},
      {:jason, "~> 1.4"},
      {:plug, "~> 1.16"},
      {:req, "~> 0.5"},
      {:reverse_proxy_plug, "~> 3.0"},
      {:reverse_proxy_plug_websocket, "~> 0.2"},
      {:websockex, "~> 0.5"}
    ]
  end
end