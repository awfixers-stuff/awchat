defmodule Gateway.Delivery do
  @moduledoc false
  import Ecto.Query

  alias Gateway.ConnectionRegistry
  alias Gateway.EnvelopeHotQueue
  alias Gateway.Repo
  alias Gateway.Schemas.{EnvelopeRecipient, MessageEnvelope}
  alias Gateway.Chats

  @spec handle_outbound(String.t(), map()) :: {:ok, map()} | {:error, atom()}
  def handle_outbound(sender_id, frame) do
    with {:ok, envelope} <- normalize_envelope(sender_id, frame),
         :ok <- ensure_chat_membership(envelope),
         {:ok, stored} <- persist_envelope(envelope),
         :ok <- fanout_or_queue(stored) do
      {:ok, stored}
    end
  end

  @spec handle_ack(String.t(), map()) :: :ok | {:error, atom()}
  def handle_ack(recipient_id, %{"envelopeId" => envelope_id}) do
    now = Gateway.Time.now()
    EnvelopeHotQueue.ack(recipient_id, envelope_id)

    Repo.transaction(fn ->
      Repo.update_all(
        from(r in EnvelopeRecipient,
          where: r.envelope_id == ^envelope_id and r.recipient_id == ^recipient_id
        ),
        set: [delivered_at: now]
      )

      maybe_delete_envelope!(envelope_id)
    end)

    :ok
  end

  def handle_ack(_recipient_id, _), do: {:error, :invalid_frame}

  @spec handle_nack(String.t(), map()) :: :ok
  def handle_nack(_recipient_id, %{"envelopeId" => envelope_id}) do
    # Redelivery happens on reconnect; nack is acknowledged without extra state.
    _ = envelope_id
    :ok
  end

  def handle_nack(_, _), do: :ok

  @spec redeliver_pending(String.t()) :: :ok
  def redeliver_pending(recipient_id) do
    hot_ids = EnvelopeHotQueue.pop_ids(recipient_id) |> MapSet.new()

    pending =
      from(e in MessageEnvelope,
        join: r in EnvelopeRecipient,
        on: r.envelope_id == e.id,
        where: r.recipient_id == ^recipient_id and is_nil(r.delivered_at),
        select: e
      )
      |> Repo.all()

    pending_by_id = Map.new(pending, &{&1.id, &1})

    extra_ids =
      hot_ids
      |> MapSet.to_list()
      |> Enum.reject(&Map.has_key?(pending_by_id, &1))

    extra_envelopes =
      if extra_ids == [] do
        []
      else
        from(e in MessageEnvelope, where: e.id in ^extra_ids)
        |> Repo.all()
      end

    (pending ++ extra_envelopes)
    |> Enum.uniq_by(& &1.id)
    |> Enum.each(fn envelope ->
      send_to_user(recipient_id, envelope_to_frame(envelope))
    end)

    :ok
  end

  defp normalize_envelope(sender_id, frame) do
    with id when is_binary(id) <- Map.get(frame, "id"),
         chat_id when is_binary(chat_id) <- Map.get(frame, "chatId"),
         ciphertext_b64 when is_binary(ciphertext_b64) <- Map.get(frame, "ciphertext"),
         {:ok, ciphertext} <- Base.decode64(ciphertext_b64) do
      sent_at =
        case Map.get(frame, "sentAt") do
          nil -> Gateway.Time.now()
          value -> parse_time(value)
        end

      purge_after =
        case Map.get(frame, "purgeAfter") do
          nil -> Gateway.Time.add_hours(sent_at, Gateway.RelayCore.envelope_ttl_hours())
          value -> parse_time(value)
        end

      {:ok,
       %{
         id: id,
         chat_id: chat_id,
         sender_id: sender_id,
         ciphertext: ciphertext,
         created_at: sent_at,
         purge_after: purge_after
       }}
    else
      :error -> {:error, :invalid_base64}
      _ -> {:error, :invalid_frame}
    end
  end

  defp ensure_chat_membership(%{chat_id: chat_id, sender_id: sender_id}) do
    if Chats.member?(chat_id, sender_id), do: :ok, else: {:error, :forbidden}
  end

  defp persist_envelope(envelope) do
    recipients = Chats.member_ids(envelope.chat_id) |> Enum.reject(&(&1 == envelope.sender_id))

    Repo.transaction(fn ->
      %MessageEnvelope{}
      |> Ecto.Changeset.change(envelope)
      |> Repo.insert!(on_conflict: :nothing)

      Enum.each(recipients, fn recipient_id ->
        %EnvelopeRecipient{}
        |> Ecto.Changeset.change(%{
          envelope_id: envelope.id,
          recipient_id: recipient_id,
          delivered_at: nil
        })
        |> Repo.insert!(on_conflict: :nothing)
      end)
    end)

    frame = envelope_to_frame(envelope)

    {:ok,
     frame
     |> Map.put("_recipients", recipients)
     |> Map.put("_purge_after", envelope.purge_after)}
  end

  defp fanout_or_queue(%{"id" => _} = frame) do
    recipients = Map.get(frame, "_recipients", [])
    purge_after = Map.get(frame, "_purge_after") || Gateway.Time.add_hours(Gateway.Time.now(), Gateway.RelayCore.envelope_ttl_hours())

    payload =
      frame
      |> Map.delete("_recipients")
      |> Map.delete("_purge_after")

    Enum.each(recipients, fn recipient_id ->
      case ConnectionRegistry.lookup(recipient_id) do
        nil ->
          EnvelopeHotQueue.push(recipient_id, payload["id"], purge_after)
          :queued

        _pid ->
          send_to_user(recipient_id, payload)
      end
    end)

    :ok
  end

  defp maybe_delete_envelope!(envelope_id) do
    pending? =
      Repo.exists?(
        from(r in EnvelopeRecipient,
          where: r.envelope_id == ^envelope_id and is_nil(r.delivered_at)
        )
      )

    unless pending? do
      Repo.delete_all(from(e in MessageEnvelope, where: e.id == ^envelope_id))
    end
  end

  defp send_to_user(user_id, frame) do
    case ConnectionRegistry.lookup(user_id) do
      nil ->
        :queued

      pid ->
        send(pid, {:relay_frame, frame})
        :ok
    end
  end

  defp envelope_to_frame(envelope) when is_map(envelope) do
    %{
      "type" => "envelope",
      "id" => envelope.id,
      "chatId" => envelope.chat_id,
      "senderId" => envelope.sender_id,
      "ciphertext" => Base.encode64(envelope.ciphertext),
      "sentAt" => Gateway.Time.iso8601(envelope.created_at)
    }
  end

  defp parse_time(value) when is_binary(value) do
    case Gateway.Time.parse_iso8601(value) do
      {:ok, dt} -> dt
      _ -> Gateway.Time.now()
    end
  end

  defp parse_time(_), do: Gateway.Time.now()
end