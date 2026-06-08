defmodule Gateway.RelayCore do
  @moduledoc """
  Elixir facade for Gleam protocol constants and validation.
  Mirrors `packages/core` until Gleam OTP 28 beams are used in production.
  """

  @user_id_prefix "awchat:"
  @max_group_size 5
  @replay_window_seconds 120
  @auth_nonce_ttl_seconds 120
  @envelope_ttl_hours 48
  @stale_prekey_hours 24

  def user_id_prefix, do: @user_id_prefix
  def max_group_size, do: @max_group_size
  def replay_window_seconds, do: @replay_window_seconds
  def auth_nonce_ttl_seconds, do: @auth_nonce_ttl_seconds
  def envelope_ttl_hours, do: @envelope_ttl_hours
  def stale_prekey_hours, do: @stale_prekey_hours

  def valid_user_id?(user_id) when is_binary(user_id) do
    String.starts_with?(user_id, @user_id_prefix) and
      String.length(user_id) > String.length(@user_id_prefix)
  end

  def valid_user_id?(_), do: false

  def valid_group_size?(count) when is_integer(count) do
    count >= 1 and count <= @max_group_size
  end

  def valid_group_size?(_), do: false

  def within_replay_window?(server_unix, timestamp_unix)
      when is_integer(server_unix) and is_integer(timestamp_unix) do
    abs(server_unix - timestamp_unix) <= @replay_window_seconds
  end
end