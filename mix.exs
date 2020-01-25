defmodule Vutuv.MixProject do
  use Mix.Project

  def project do
    [
      app: :vutuv,
      version: "0.1.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        ignore_warnings: "dialyzer.ignore_warnings.exs",
        plt_add_deps: :transitive,
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  def application do
    [
      mod: {Vutuv.Application, []},
      extra_applications: [:logger, :runtime_tools, :inets]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.4.1"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      # Care needed when upgrading to 3.1 - tests failing with unknown field errors
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:scrivener_ecto, "~> 2.2"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:dialyxir, "~> 1.0.0-rc.3", only: :dev, runtime: false},
      {:ex_machina, "~> 2.3", only: :test},
      {:faker, "~> 0.12.0", only: :test},
      {:gettext, "~> 0.17.0"},
      {:jason, "~> 1.0"},
      {:phauxth, "~> 2.2.0"},
      {:argon2_elixir, "~> 2.0"},
      {:not_qwerty123, "~> 2.3"},
      {:one_time_pass_ecto, "~> 1.0"},
      {:hammer, "~> 6.0"},
      {:tesla, "~> 1.2.1"},
      {:hackney, "~> 1.14.0"},
      {:bamboo, "~> 1.3"},
      {:plug_cowboy, "~> 2.0"},
      {:arc, "~> 0.11.0"},
      {:arc_ecto, git: "https://github.com/hendri-tobing/arc_ecto.git"},
      {:slugger, "~> 0.3.0"}
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
