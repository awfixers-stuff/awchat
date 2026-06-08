import Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise "DATABASE_URL is required in production"

config :gateway, Gateway.Repo, url: database_url, pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

config :gateway, Gateway.Endpoint,
  port: String.to_integer(System.get_env("PORT") || "8081")