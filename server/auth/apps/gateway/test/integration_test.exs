defmodule Gateway.IntegrationTest do
  use Gateway.DataCase, async: false

  @moduletag :integration

  setup_all do
    {:ok, _} = Application.ensure_all_started(:gateway)
    :ok
  end

  test "resolve missing invite returns 404" do
    conn =
      :get
      |> Plug.Test.conn("/v1/invites/missing-token")
      |> Gateway.Router.call([])

    assert conn.status == 404
    assert Jason.decode!(conn.resp_body) == %{"error" => "not_found"}
  end
end