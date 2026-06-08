defmodule Gateway.AuthCore do
  @moduledoc false

  @user_id_prefix "awchat:"
  @replay_window_seconds 120
  @token_bytes 24

  def user_id_prefix, do: @user_id_prefix
  def replay_window_seconds, do: @replay_window_seconds
  def token_bytes, do: @token_bytes

  def valid_user_id?(user_id) when is_binary(user_id) do
    String.starts_with?(user_id, @user_id_prefix) and
      String.length(user_id) > String.length(@user_id_prefix)
  end

  def valid_user_id?(_), do: false
end