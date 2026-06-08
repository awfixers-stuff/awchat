import Config

config :gateway, Gateway.Repo,
  username: System.get_env("POSTGRES_USER") || "awchat",
  password: System.get_env("POSTGRES_PASSWORD") || "awchat",
  hostname: System.get_env("POSTGRES_HOST") || "localhost",
  database: System.get_env("POSTGRES_DB") || "awchat_relay_dev",
  port: String.to_integer(System.get_env("POSTGRES_PORT") || "5432"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :gateway, Gateway.Endpoint, port: 8080