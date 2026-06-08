defmodule Gateway.Addresses do
  @moduledoc false
  alias Gateway.Repo
  alias Gateway.Schemas.{Address, ConnectionRequest}

  @spec create(String.t(), map()) :: {:ok, map()} | {:error, atom()}
  def create(owner_id, params) do
    token = Gateway.Tokens.generate()
    auto_accept = Map.get(params, "autoAccept", false) == true
    now = Gateway.Time.now()

    %Address{}
    |> Ecto.Changeset.change(%{
      token: token,
      owner_id: owner_id,
      auto_accept: auto_accept,
      created_at: now
    })
    |> Repo.insert!()

    {:ok,
     %{
       "token" => token,
       "uri" => Gateway.Tokens.address_uri(token),
       "autoAccept" => auto_accept,
       "createdAt" => Gateway.Time.iso8601(now)
     }}
  end

  @spec resolve(String.t()) :: {:ok, map()} | {:error, atom()}
  def resolve(token) do
    case Repo.get(Address, token) do
      %Address{revoked_at: nil} = address ->
        {:ok,
         %{
           "valid" => true,
           "uri" => Gateway.Tokens.address_uri(address.token)
         }}

      %Address{} ->
        {:error, :revoked}

      nil ->
        {:error, :not_found}
    end
  end

  @spec revoke(String.t(), String.t()) :: :ok | {:error, atom()}
  def revoke(token, owner_id) do
    case Repo.get(Address, token) do
      %Address{owner_id: ^owner_id, revoked_at: nil} = address ->
        address
        |> Ecto.Changeset.change(%{revoked_at: Gateway.Time.now()})
        |> Repo.update!()

        :ok

      %Address{owner_id: ^owner_id} ->
        :ok

      %Address{} ->
        {:error, :forbidden}

      nil ->
        {:error, :not_found}
    end
  end

  @spec submit_request(String.t(), String.t(), map()) :: {:ok, map()} | {:error, atom()}
  def submit_request(token, requester_id, params) do
    with {:ok, display_name} <- fetch_display_name(params),
         %Address{owner_id: owner_id, revoked_at: nil} = address <- Repo.get(Address, token) || {:error, :not_found},
         false <- owner_id == requester_id,
         {:ok, request} <- create_request(address, requester_id, display_name) do
      {:ok, serialize_request(request)}
    else
      true -> {:error, :self_request}
      {:error, reason} -> {:error, reason}
      nil -> {:error, :not_found}
      %Address{} -> {:error, :revoked}
    end
  end

  defp fetch_display_name(%{"displayName" => name}) when is_binary(name) and name != "",
    do: {:ok, name}

  defp fetch_display_name(_), do: {:error, :invalid_payload}

  defp create_request(%Address{} = address, requester_id, display_name) do
    now = Gateway.Time.now()
    status = if address.auto_accept, do: "accepted", else: "pending"
    responded_at = if address.auto_accept, do: now, else: nil

    %ConnectionRequest{}
    |> Ecto.Changeset.change(%{
      id: request_id(),
      recipient_id: address.owner_id,
      requester_id: requester_id,
      display_name: display_name,
      source_type: "address",
      source_token: address.token,
      status: status,
      created_at: now,
      responded_at: responded_at
    })
    |> Repo.insert()
  end

  defp request_id, do: "req_" <> Base.url_encode64(:crypto.strong_rand_bytes(12), padding: false)

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