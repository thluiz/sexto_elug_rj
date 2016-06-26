# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :sexto_elug_rj,
  ecto_repos: [SextoElugRj.Repo]

# Configures the endpoint
config :sexto_elug_rj, SextoElugRj.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "2B3eeuz9SzXEBZq96+o0JdzMTCXANui0jc4k9CnEBtbapyvNC21xVP2Ikd6fE6+K",
  render_errors: [view: SextoElugRj.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SextoElugRj.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
