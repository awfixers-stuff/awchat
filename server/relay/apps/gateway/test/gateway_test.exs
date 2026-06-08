defmodule GatewayTest do
  use ExUnit.Case, async: true

  test "relay core validation helpers" do
    assert Gateway.RelayCore.valid_user_id?("awchat:abc")
    assert Gateway.RelayCore.replay_window_seconds() == 120
    assert Gateway.RelayCore.valid_group_size?(5)
    refute Gateway.RelayCore.valid_group_size?(6)
  end
end