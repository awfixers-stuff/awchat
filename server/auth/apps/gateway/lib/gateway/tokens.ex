defmodule Gateway.Tokens do
  @moduledoc false

  @spec generate() :: String.t()
  def generate do
    Gateway.AuthCore.token_bytes()
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
  end

  @spec invite_uri(String.t()) :: String.t()
  def invite_uri(token), do: "awchat://i/#{token}"

  @spec address_uri(String.t()) :: String.t()
  def address_uri(token), do: "awchat://a/#{token}"
end