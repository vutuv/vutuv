# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :vutuv,
  ecto_repos: [Vutuv.Repo]

# Configures the endpoint
config :vutuv, VutuvWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "El6ZY1nmAy34kdamp7nLitACVIqRMf8pmECKq9FW5g8vBmHyEada65F6EE3p0CNh",
  render_errors: [view: VutuvWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Vutuv.PubSub, adapter: Phoenix.PubSub.PG2]

# Phauxth authentication configuration
config :phauxth,
  user_context: Vutuv.Accounts,
  crypto_module: Argon2,
  token_module: VutuvWeb.Auth.Token

# Mailer configuration
config :vutuv, VutuvWeb.Mailer, adapter: Bamboo.LocalAdapter

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
