defmodule Gateway.Chats do
  @moduledoc false
  import Ecto.Query

  alias Gateway.Repo
  alias Gateway.Schemas.{Chat, ChatMember}

  @spec create_or_upsert(String.t(), map()) :: {:ok, map()} | {:error, atom()}
  def create_or_upsert(caller_id, params) do
    with {:ok, chat_id} <- fetch_chat_id(params),
         {:ok, chat_type} <- fetch_chat_type(params),
         {:ok, member_ids} <- fetch_member_ids(params),
         true <- Enum.member?(member_ids, caller_id),
         true <- Gateway.RelayCore.valid_group_size?(length(member_ids)),
         true <- Enum.all?(member_ids, &Gateway.RelayCore.valid_user_id?/1) do
      now = Gateway.Time.now()

      Repo.transaction(fn ->
        upsert_chat!(chat_id, chat_type, now)
        replace_members!(chat_id, member_ids)
      end)

      {:ok,
       %{
         "chatId" => chat_id,
         "type" => chat_type,
         "members" => member_ids,
         "createdAt" => Gateway.Time.iso8601(now)
       }}
    else
      false -> {:error, :forbidden}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec get(String.t()) :: {:ok, map()} | {:error, atom()}
  def get(chat_id) do
    case Repo.get(Chat, chat_id) do
      nil ->
        {:error, :not_found}

      %Chat{} = chat ->
        members = member_ids(chat_id)

        {:ok,
         %{
           "chatId" => chat.id,
           "type" => chat.type,
           "members" => members,
           "createdAt" => Gateway.Time.iso8601(chat.created_at)
         }}
    end
  end

  @spec get_for_member(String.t(), String.t()) :: {:ok, map()} | {:error, atom()}
  def get_for_member(chat_id, caller_id) do
    case Repo.get(Chat, chat_id) do
      nil ->
        {:error, :not_found}

      %Chat{} ->
        if member?(chat_id, caller_id) do
          get(chat_id)
        else
          {:error, :forbidden}
        end
    end
  end

  @spec update_members(String.t(), String.t(), map()) :: {:ok, map()} | {:error, atom()}
  def update_members(caller_id, chat_id, params) do
    with %Chat{type: "group"} <- Repo.get(Chat, chat_id),
         true <- member?(chat_id, caller_id),
         {:ok, added} <- fetch_id_list(params, "add"),
         {:ok, removed} <- fetch_id_list(params, "remove"),
         current = member_ids(chat_id),
         {:ok, updated} <- apply_membership_changes(current, added, removed) do
      Repo.transaction(fn ->
        Enum.each(removed, fn user_id ->
          Repo.delete_all(
            from(m in ChatMember, where: m.chat_id == ^chat_id and m.user_id == ^user_id)
          )
        end)

        Enum.each(added, fn user_id ->
          %ChatMember{}
          |> Ecto.Changeset.change(%{chat_id: chat_id, user_id: user_id})
          |> Repo.insert!(on_conflict: :nothing)
        end)
      end)

      now = Gateway.Time.now()

      {:ok,
       %{
         "chatId" => chat_id,
         "added" => added,
         "removed" => removed,
         "members" => updated,
         "changedBy" => caller_id,
         "changedAt" => Gateway.Time.iso8601(now)
       }}
    else
      %Chat{type: "direct"} -> {:error, :direct_chat_immutable}
      false -> {:error, :forbidden}
      nil -> {:error, :not_found}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec member?(String.t(), String.t()) :: boolean()
  def member?(chat_id, user_id) do
    Repo.exists?(
      from(m in ChatMember, where: m.chat_id == ^chat_id and m.user_id == ^user_id)
    )
  end

  @spec member_ids(String.t()) :: [String.t()]
  def member_ids(chat_id) do
    from(m in ChatMember, where: m.chat_id == ^chat_id, select: m.user_id)
    |> Repo.all()
  end

  defp fetch_chat_id(%{"chatId" => chat_id}) when is_binary(chat_id), do: {:ok, chat_id}
  defp fetch_chat_id(%{"id" => chat_id}) when is_binary(chat_id), do: {:ok, chat_id}
  defp fetch_chat_id(_), do: {:error, :invalid_payload}

  defp fetch_chat_type(%{"type" => type}) when type in ["direct", "group"], do: {:ok, type}
  defp fetch_chat_type(%{"chatType" => type}) when type in ["direct", "group"], do: {:ok, type}
  defp fetch_chat_type(_), do: {:error, :invalid_payload}

  defp fetch_member_ids(%{"memberIds" => ids}) when is_list(ids), do: {:ok, Enum.uniq(ids)}
  defp fetch_member_ids(%{"members" => ids}) when is_list(ids), do: {:ok, Enum.uniq(ids)}
  defp fetch_member_ids(_), do: {:error, :invalid_payload}

  defp fetch_id_list(params, field) do
    case Map.get(params, field, []) do
      ids when is_list(ids) -> {:ok, ids}
      _ -> {:error, :invalid_payload}
    end
  end

  defp apply_membership_changes(current, added, removed) do
    updated =
      current
      |> Enum.reject(&(&1 in removed))
      |> Kernel.++(added)
      |> Enum.uniq()

    if Gateway.RelayCore.valid_group_size?(length(updated)) do
      {:ok, updated}
    else
      {:error, :group_too_large}
    end
  end

  defp upsert_chat!(chat_id, chat_type, now) do
    %Chat{}
    |> Ecto.Changeset.change(%{id: chat_id, type: chat_type, created_at: now})
    |> Repo.insert!(on_conflict: :nothing)
  end

  defp replace_members!(chat_id, member_ids) do
    Repo.delete_all(from(m in ChatMember, where: m.chat_id == ^chat_id))

    Enum.each(member_ids, fn user_id ->
      %ChatMember{}
      |> Ecto.Changeset.change(%{chat_id: chat_id, user_id: user_id})
      |> Repo.insert!()
    end)
  end
end