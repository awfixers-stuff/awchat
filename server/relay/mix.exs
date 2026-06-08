defmodule Relay.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      releases: releases(),
      deps: deps()
    ]
  end

  defp releases do
    [
      relay: [
        applications: [gateway: :permanent],
        steps: [:assemble, :tar]
      ]
    ]
  end

  defp deps do
    []
  end
end