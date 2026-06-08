defmodule Gateway.Plugs.JsonParser do
  @moduledoc false
  import Plug.Conn

  def init(opts), do: opts

  def call(%Plug.Conn{assigns: %{raw_body: body}} = conn, _opts) when is_binary(body) do
    if body == "" do
      %{conn | body_params: %{}}
    else
      case Jason.decode(body) do
        {:ok, params} -> %{conn | body_params: params}
        {:error, _} -> conn |> put_resp_content_type("application/json") |> send_resp(400, ~s({"error":"invalid_json"})) |> halt()
      end
    end
  end

  def call(conn, _opts), do: %{conn | body_params: %{}}
end