import Config

if config_env() == :prod do
  config :broker, :port, String.to_integer(System.get_env("PORT") || "8080")

  config :broker,
    relay_upstream: System.get_env("RELAY_UPSTREAM") || raise("RELAY_UPSTREAM is required"),
    auth_upstream: System.get_env("AUTH_UPSTREAM") || raise("AUTH_UPSTREAM is required"),
    ops_token: System.get_env("BROKER_OPS_TOKEN") || raise("BROKER_OPS_TOKEN is required")
end