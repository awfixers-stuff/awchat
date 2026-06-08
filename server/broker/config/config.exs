import Config

config :broker, :port, String.to_integer(System.get_env("PORT") || "8080")

config :broker, :redis_url, System.get_env("REDIS_URL")

config :broker,
  relay_upstream: System.get_env("RELAY_UPSTREAM") || "localhost:8080",
  auth_upstream: System.get_env("AUTH_UPSTREAM") || "localhost:8081",
  ops_token: System.get_env("BROKER_OPS_TOKEN"),
  max_body_bytes: String.to_integer(System.get_env("MAX_BODY_BYTES") || "1048576"),
  ip_rate_limit: String.to_integer(System.get_env("IP_RATE_LIMIT") || "120"),
  user_rate_limit: String.to_integer(System.get_env("USER_RATE_LIMIT") || "60"),
  rate_limit_window_ms: String.to_integer(System.get_env("RATE_LIMIT_WINDOW_MS") || "60000")

config :reverse_proxy_plug, :http_client, ReverseProxyPlug.HTTPClient.Adapters.Req

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :route]

import_config "#{config_env()}.exs"