# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :vutuv, Vutuv.Endpoint,
  root: Path.dirname(__DIR__),
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Vutuv.PubSub,
           adapter: Phoenix.PubSub.PG2],
  locales: ~w(en de),
  max_image_filesize: 2000000,
  max_page_items: 250,
  srv_attachment_path: "" # where the files are stored

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
if(File.exists?("config/#{Mix.env}.secret.exs")) do
  import_config "#{Mix.env}.secret.exs"
end

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :vutuv, ecto_repos: [Vutuv.Repo]
