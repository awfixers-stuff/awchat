defmodule Broker.Config do
  @moduledoc false

  def port, do: Application.get_env(:broker, :port)

  def relay_upstream, do: Application.get_env(:broker, :relay_upstream)

  def auth_upstream, do: Application.get_env(:broker, :auth_upstream)

  def ops_token, do: Application.get_env(:broker, :ops_token)

  def max_body_bytes, do: Application.get_env(:broker, :max_body_bytes)

  def ip_rate_limit, do: Application.get_env(:broker, :ip_rate_limit)

  def user_rate_limit, do: Application.get_env(:broker, :user_rate_limit)

  def rate_limit_window_ms, do: Application.get_env(:broker, :rate_limit_window_ms)

  def relay_http_url, do: "http://" <> relay_upstream()

  def auth_http_url, do: "http://" <> auth_upstream()

  def relay_ws_url, do: "ws://" <> relay_upstream()
end