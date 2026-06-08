import Config

config :gateway, ecto_repos: [Gateway.Repo]

config :gateway, Gateway.Repo,
  migration_timestamps: [type: :utc_datetime_usec]

config :gateway, Gateway.Endpoint,
  port: String.to_integer(System.get_env("PORT") || "8080")

config :gateway, Gateway.Scheduler,
  jobs: [
    {"*/15 * * * *", {Gateway.Jobs, :purge_expired_envelopes, []}},
    {"*/5 * * * *", {Gateway.Jobs, :purge_expired_nonces, []}},
    {"0 * * * *", {Gateway.Jobs, :purge_stale_prekeys, []}}
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :route]

import_config "#{config_env()}.exs"