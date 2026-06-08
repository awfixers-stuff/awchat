defmodule Gateway.ControllersTest do
  use ExUnit.Case, async: true

  test "health endpoint" do
    conn =
      :get
      |> Plug.Test.conn("/v1/health")
      |> Gateway.Router.call([])

    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{"status" => "ok"}
  end

  test "unknown route returns 404" do
    conn =
      :get
      |> Plug.Test.conn("/v1/unknown")
      |> Gateway.Router.call([])

    assert conn.status == 404
    assert Jason.decode!(conn.resp_body) == %{"error" => "not_found"}
  end

  test "protected endpoint requires auth" do
    conn =
      :post
      |> Plug.Test.conn("/v1/invites", Jason.encode!(%{}))
      |> Plug.Conn.put_req_header("content-type", "application/json")
      |> Gateway.Router.call([])

    assert conn.status == 401
    assert Jason.decode!(conn.resp_body) == %{"error" => "unauthorized"}
  end

end