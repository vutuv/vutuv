defmodule Vutuv.Mixfile do
  use Mix.Project

  def project do
    [app: :vutuv,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Vutuv, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger, :gettext,
<<<<<<< HEAD
                    :phoenix_ecto, :postgrex, :ex_machina, :phoenix_html_simplified_helpers, :bamboo, :bamboo_smtp]]
=======
                    :phoenix_ecto, :mariaex, :ex_machina, 
                    :phoenix_html_simplified_helpers, :bamboo]]
>>>>>>> af6cc72ae7f58fc1fd35177309ddcb94dd35257f
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:ecto, "~> 2.0.0", override: true},
     {:bamboo, "~> 0.6"},
     {:bamboo_smtp, "~> 1.1.0"},
     {:phoenix, "~> 1.1.0"},
     {:phoenix_ecto, "~> 3.0.0-rc"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.3"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.9"},
     {:cowboy, "~> 1.0"},
     {:arc, "~> 0.5.2"},
     {:arc_ecto, "~> 0.4.2"},
     {:ex_machina, "~> 0.6.1"},
<<<<<<< HEAD
     {:phoenix_html_simplified_helpers, "~> 0.6.0"}]
=======
     {:phoenix_html_simplified_helpers, "~> 0.3.3"},
     {:bamboo, "~> 0.7"}]
>>>>>>> af6cc72ae7f58fc1fd35177309ddcb94dd35257f
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
