defmodule BrokerTest do
  use ExUnit.Case, async: true
  import Plug.Conn

  alias Broker.Route

  describe "Route.classify/1" do
    test "routes auth paths to auth upstream" do
      for path <- [
            "/v1/identities",
            "/v1/invites/foo",
            "/v1/addresses/bar",
            "/v1/connection-requests"
          ] do
        conn = build_conn("GET", path)
        assert Route.classify(conn) == :auth
      end
    end

    test "routes websocket upgrade on /v1/ws to relay ws proxy" do
      conn =
        :get
        |> Plug.Test.conn("/v1/ws")
        |> put_req_header("upgrade", "websocket")
        |> put_req_header("connection", "Upgrade")

      assert Route.classify(conn) == :ws
    end

    test "routes other /v1 paths to relay" do
      conn = build_conn("GET", "/v1/health")
      assert Route.classify(conn) == :relay
    end

    test "returns not_found for unknown paths" do
      conn = build_conn("GET", "/unknown")
      assert Route.classify(conn) == :not_found
    end
  end

  describe "GET /health" do
    test "returns ok" do
      conn = Broker.Router.call(build_conn("GET", "/health"), [])
      assert conn.status == 200
      assert conn.resp_body == "ok"
    end
  end

  describe "GET /ops/status" do
    test "requires ops token" do
      conn = Broker.Router.call(build_conn("GET", "/ops/status"), [])
      assert conn.status == 401
    end

    test "accepts valid ops token" do
      conn =
        build_conn("GET", "/ops/status")
        |> put_req_header("x-ops-token", "test-ops-token")

      conn = Broker.Router.call(conn, [])
      assert conn.status == 200
      assert %{"broker" => %{"status" => "ok"}} = Jason.decode!(conn.resp_body)
    end
  end

  describe "security headers" do
    test "are set on health responses" do
      conn = Broker.Router.call(build_conn("GET", "/health"), [])
      assert get_resp_header(conn, "strict-transport-security") != []
      assert get_resp_header(conn, "x-content-type-options") == ["nosniff"]
    end
  end

  describe "rate limiting" do
    test "returns 429 when ip limit exceeded" do
      window = Application.get_env(:broker, :rate_limit_window_ms)
      limit = Application.get_env(:broker, :ip_rate_limit)

      for _ <- 1..limit do
        Broker.RateLimiter.hit("ip:203.0.113.9", window, limit)
      end

      conn =
        build_conn("GET", "/v1/health")
        |> Map.put(:remote_ip, {203, 0, 113, 9})

      conn = Broker.Router.call(conn, [])
      assert conn.status == 429
      assert %{"code" => "rate_limited"} = Jason.decode!(conn.resp_body)
    end
  end

  defp build_conn(method, path) do
    Plug.Test.conn(method, path)
  end
end