# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :pingal_server,
  ecto_repos: [PingalServer.Repo]

# Configures the endpoint
config :pingal_server, PingalServer.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "OkQT0h0zjWPbgoGvv5bowc151aR2/BrRO3NMNJnQJoh/ebB0uDg5dpD7bCU4FPUx",
  render_errors: [view: PingalServer.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PingalServer.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
