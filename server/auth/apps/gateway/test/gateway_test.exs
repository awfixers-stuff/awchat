defmodule GatewayTest do
  use ExUnit.Case, async: true

  test "auth core validation" do
    assert Gateway.AuthCore.valid_user_id?("awchat:ABC123")
    assert Gateway.AuthCore.replay_window_seconds() == 120
    refute Gateway.AuthCore.valid_user_id?("awchat:")
    refute Gateway.AuthCore.valid_user_id?("other:ABC")
  end

  test "token uris" do
    token = "abc123"
    assert Gateway.Tokens.invite_uri(token) == "awchat://i/abc123"
    assert Gateway.Tokens.address_uri(token) == "awchat://a/abc123"
  end

  test "base32 encodes sha256 fingerprint prefix" do
    hash = :crypto.hash(:sha256, <<0, 1, 2, 3>>)
    encoded = Gateway.Base32.encode(hash)
    assert String.match?(encoded, ~r/^[A-Z2-7]+$/)
    assert byte_size(encoded) > 0
  end
end