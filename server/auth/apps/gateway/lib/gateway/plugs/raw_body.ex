defmodule Gateway.Plugs.RawBody do
  @moduledoc false
  import Plug.Conn

  def init(opts), do: opts

  def call(%Plug.Conn{method: "GET"} = conn, _opts), do: conn
  def call(%Plug.Conn{method: "HEAD"} = conn, _opts), do: conn
  def call(%Plug.Conn{method: "DELETE"} = conn, _opts), do: conn

  def call(conn, _opts) do
    case read_body(conn) do
      {:ok, body, conn} -> assign(conn, :raw_body, body)
      {:more, _, conn} -> assign(conn, :raw_body, "")
      {:error, _} -> assign(conn, :raw_body, "")
    end
  end
end