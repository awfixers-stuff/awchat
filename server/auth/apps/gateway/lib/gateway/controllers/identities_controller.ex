defmodule Gateway.Controllers.IdentitiesController do
  @moduledoc false
  import Gateway.Controllers.Helpers

  def create(conn, _params) do
    case Gateway.Identities.register(conn.body_params) do
      {:ok, body} ->
        json(conn, 201, body)

      {:error, :invalid_proof} ->
        error(conn, 400, "invalid_proof")

      {:error, :invalid_user_id} ->
        error(conn, 400, "invalid_user_id")

      {:error, _} ->
        error(conn, 400, "invalid_payload")
    end
  end

end