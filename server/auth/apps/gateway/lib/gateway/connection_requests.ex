defmodule Gateway.ConnectionRequests do
  @moduledoc false
  import Ecto.Query
  alias Gateway.Repo
  alias Gateway.Schemas.ConnectionRequest

  @spec list_pending(String.t()) :: {:ok, map()}
  def list_pending(recipient_id) do
    requests =
      from(r in ConnectionRequest,
        where: r.recipient_id == ^recipient_id and r.status == "pending",
        order_by: [desc: r.created_at]
      )
      |> Repo.all()
      |> Enum.map(&serialize_request/1)

    {:ok, %{"requests" => requests}}
  end

  @spec respond(String.t(), String.t(), map()) :: {:ok, map()} | {:error, atom()}
  def respond(recipient_id, request_id, params) do
    with {:ok, action} <- fetch_action(params),
         %ConnectionRequest{recipient_id: ^recipient_id, status: "pending"} = request <-
           Repo.get(ConnectionRequest, request_id) || {:error, :not_found} do
      now = Gateway.Time.now()
      status = if action == "accept", do: "accepted", else: "rejected"

      request
      |> Ecto.Changeset.change(%{status: status, responded_at: now})
      |> Repo.update!()
      |> serialize_request()
      |> then(&{:ok, &1})
    else
      %ConnectionRequest{} -> {:error, :forbidden}
      {:error, reason} -> {:error, reason}
      nil -> {:error, :not_found}
    end
  end

  defp fetch_action(%{"action" => "accept"}), do: {:ok, "accept"}
  defp fetch_action(%{"action" => "reject"}), do: {:ok, "reject"}
  defp fetch_action(_), do: {:error, :invalid_payload}

  defp serialize_request(%ConnectionRequest{} = request) do
    %{
      "id" => request.id,
      "status" => request.status,
      "recipientUserId" => request.recipient_id,
      "requesterUserId" => request.requester_id,
      "displayName" => request.display_name,
      "sourceType" => request.source_type,
      "createdAt" => Gateway.Time.iso8601(request.created_at),
      "respondedAt" => maybe_iso8601(request.responded_at)
    }
  end

  defp maybe_iso8601(nil), do: nil
  defp maybe_iso8601(%DateTime{} = dt), do: Gateway.Time.iso8601(dt)
end