use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :vutuv, VutuvWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :vutuv, Vutuv.Repo,
  username: "postgres",
  password: "postgres",
  database: "vutuv2_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Password hashing test config
config :argon2_elixir, t_cost: 1, m_cost: 8

# Mailer test configuration
config :vutuv, VutuvWeb.Mailer, adapter: Bamboo.TestAdapter
