defmodule Vutuv.MixProject do
  use Mix.Project

  def project do
    [
      app: :vutuv,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_add_deps: :transitive,
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  def application do
    [
      mod: {Vutuv.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.4.1"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:dialyxir, "~> 1.0.0-rc.3", only: :dev, runtime: false},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:phauxth, "~> 2.1.0"},
      {:argon2_elixir, "~> 2.0"},
      {:bamboo, "~> 1.1"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
