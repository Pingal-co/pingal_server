use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :pingal_server, PingalServer.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :pingal_server, PingalServer.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "rohit",
  password: "Pingal123",
  database: "pingal_server_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
