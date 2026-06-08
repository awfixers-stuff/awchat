defmodule Gateway.Purge do
  @moduledoc false
  import Ecto.Query

  alias Gateway.Chats
  alias Gateway.ConnectionRegistry
  alias Gateway.Repo
  alias Gateway.Schemas.{MessageEnvelope, PurgeAudit}

  @spec purge_message(String.t(), map()) :: {:ok, map()} | {:error, atom()}
  def purge_message(caller_id, %{"messageId" => message_id, "chatId" => chat_id}) do
    with true <- Chats.member?(chat_id, caller_id) do
      now = Gateway.Time.now()

      inserted =
        %PurgeAudit{}
        |> Ecto.Changeset.change(%{
          message_id: message_id,
          chat_id: chat_id,
          requested_by: caller_id,
          purge_received_at: now
        })
        |> Repo.insert(
          on_conflict: :nothing,
          returning: [:message_id]
        )

      case inserted do
        {:ok, %PurgeAudit{}} ->
          Repo.delete_all(from(e in MessageEnvelope, where: e.id == ^message_id))
          broadcast_purge(chat_id, message_id, now)

        {:error, _} ->
          :ok

        _ ->
          :ok
      end

      {:ok,
       %{
         "messageId" => message_id,
         "chatId" => chat_id,
         "purgedAt" => Gateway.Time.iso8601(now)
       }}
    else
      false -> {:error, :forbidden}
    end
  end

  def purge_message(_caller_id, _), do: {:error, :invalid_payload}

  defp broadcast_purge(chat_id, message_id, now) do
    frame = %{
      "type" => "purge_notify",
      "messageId" => message_id,
      "chatId" => chat_id,
      "purgedAt" => Gateway.Time.iso8601(now)
    }

    chat_id
    |> Chats.member_ids()
    |> Enum.each(fn user_id ->
      case ConnectionRegistry.lookup(user_id) do
        nil -> :ok
        pid -> send(pid, {:relay_frame, frame})
      end
    end)
  end
end