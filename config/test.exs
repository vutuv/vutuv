use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :vutuv, Vutuv.Endpoint,
  url: [host: "http://localhost:4000/", port: 4001],
  http: [port: 4001],
  server: false,
  public_url: "http://localhost:4000/"

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :vutuv, Vutuv.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASSWORD"),
  database: System.get_env("DB_DATABASE"),
  hostname: System.get_env("DB_HOST"),
  pool: Ecto.Adapters.SQL.Sandbox

config :vutuv, Vutuv.Mailer,
  adapter: Bamboo.TestAdapter
