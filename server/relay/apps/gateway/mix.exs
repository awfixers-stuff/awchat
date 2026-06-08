defmodule Gateway.MixProject do
  use Mix.Project

  def project do
    [
      app: :gateway,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      aliases: aliases(),
      deps: deps(),
      rustler_crates: [
        awchat_crypto: [
          path: "native/awchat_crypto",
          mode: rustler_mode(Mix.env())
        ]
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp rustler_mode(:prod), do: :release
  defp rustler_mode(_), do: :debug

  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {Gateway.Application, []}
    ]
  end

  defp aliases do
    compile_steps =
      if Mix.env() == :prod,
        do: ["compile"],
        else: ["compile.gleam", "compile"]

    [
      "compile.gleam": "cmd --cd ../../packages/core gleam build",
      compile: compile_steps,
      test: ["compile.gleam", "test"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"]
    ]
  end

  defp deps do
    [
      {:bandit, "~> 1.6"},
      {:ecto_sql, "~> 3.12"},
      {:jason, "~> 1.4"},
      {:postgrex, ">= 0.0.0"},
      {:quantum, "~> 3.5"},
      {:rustler, "~> 0.36"},
      {:websock_adapter, "~> 0.5"}
    ]
  end
end