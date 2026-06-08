defmodule Gateway.Controllers.ChatsController do
  @moduledoc false
  import Plug.Conn

  def create(conn, _params) do
    with {:ok, caller_id} <- auth(conn, "POST", "/v1/chats"),
         {:ok, body} <- Gateway.Chats.create_or_upsert(caller_id, conn.body_params) do
      maybe_broadcast_chat_created(caller_id, body)
      json(conn, 201, body)
    else
      {:error, :unauthorized} -> error(conn, 401, "unauthorized")
      {:error, :forbidden} -> error(conn, 403, "forbidden")
      {:error, :group_too_large} -> error(conn, 400, "group_too_large")
      {:error, _} -> error(conn, 400, "invalid_payload")
    end
  end

  def show(conn, %{"chat_id" => chat_id}) do
    case Gateway.Chats.get(chat_id) do
      {:ok, body} -> json(conn, 200, body)
      {:error, :not_found} -> error(conn, 404, "not_found")
    end
  end

  def update_members(conn, %{"chat_id" => chat_id}) do
    path = "/v1/chats/#{chat_id}/members"

    with {:ok, caller_id} <- auth(conn, "PATCH", path),
         {:ok, body} <- Gateway.Chats.update_members(caller_id, chat_id, conn.body_params) do
      broadcast_membership_changed(body)
      json(conn, 200, body)
    else
      {:error, :unauthorized} -> error(conn, 401, "unauthorized")
      {:error, :forbidden} -> error(conn, 403, "forbidden")
      {:error, :direct_chat_immutable} -> error(conn, 409, "direct_chat_immutable")
      {:error, :not_found} -> error(conn, 404, "not_found")
      {:error, _} -> error(conn, 400, "invalid_payload")
    end
  end

  defp auth(conn, method, path), do: Gateway.Auth.verify_rest(conn, method, path)

  defp maybe_broadcast_chat_created(creator_id, %{"type" => "group"} = body) do
    frame = %{
      "type" => "chat_created",
      "chatId" => body["chatId"],
      "chatType" => body["type"],
      "members" => body["members"],
      "creatorId" => creator_id,
      "createdAt" => body["createdAt"]
    }

    Enum.each(body["members"], fn user_id ->
      case Gateway.ConnectionRegistry.lookup(user_id) do
        nil -> :ok
        pid -> send(pid, {:relay_frame, frame})
      end
    end)
  end

  defp maybe_broadcast_chat_created(_creator_id, _body), do: :ok

  defp broadcast_membership_changed(body) do
    frame = %{
      "type" => "membership_changed",
      "chatId" => body["chatId"],
      "added" => body["added"],
      "removed" => body["removed"],
      "members" => body["members"],
      "changedBy" => body["changedBy"],
      "changedAt" => body["changedAt"]
    }

    Enum.each(body["members"], fn user_id ->
      case Gateway.ConnectionRegistry.lookup(user_id) do
        nil -> :ok
        pid -> send(pid, {:relay_frame, frame})
      end
    end)
  end

  defp json(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
  end

  defp error(conn, status, code) do
    json(conn, status, %{"error" => code})
  end
end