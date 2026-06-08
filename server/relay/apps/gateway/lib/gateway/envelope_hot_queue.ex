defmodule Gateway.EnvelopeHotQueue do
  @moduledoc """
  Redis-backed index of pending envelope ids per recipient.

  Postgres remains source of truth; this layer gives the broker/relay path
  durable hot state across serverless relay restarts.
  """
  @prefix "awchat:v1:pending:"

  @spec push(String.t(), String.t(), DateTime.t()) :: :ok
  def push(recipient_id, envelope_id, purge_after)
      when is_binary(recipient_id) and is_binary(envelope_id) do
    if Gateway.Redis.enabled?() do
      key = key(recipient_id)
      ttl_sec = ttl_seconds(purge_after)

      case Gateway.Redis.command(["SADD", key, envelope_id]) do
        {:ok, _} ->
          if ttl_sec > 0 do
            _ = Gateway.Redis.command(["EXPIRE", key, Integer.to_string(ttl_sec)])
          end

          :ok

        {:error, reason} ->
          require Logger
          Logger.warning("redis_pending_push_failed recipient=#{recipient_id} reason=#{inspect(reason)}")
          :ok
      end
    else
      :ok
    end
  end

  @spec pop_ids(String.t()) :: [String.t()]
  def pop_ids(recipient_id) when is_binary(recipient_id) do
    if Gateway.Redis.enabled?() do
      key = key(recipient_id)

      case Gateway.Redis.command(["SMEMBERS", key]) do
        {:ok, ids} when is_list(ids) ->
          ids

        _ ->
          []
      end
    else
      []
    end
  end

  @spec ack(String.t(), String.t()) :: :ok
  def ack(recipient_id, envelope_id)
      when is_binary(recipient_id) and is_binary(envelope_id) do
    if Gateway.Redis.enabled?() do
      _ = Gateway.Redis.command(["SREM", key(recipient_id), envelope_id])
      :ok
    else
      :ok
    end
  end

  defp key(recipient_id), do: @prefix <> recipient_id

  defp ttl_seconds(%DateTime{} = purge_after) do
    now = DateTime.utc_now()
    max(1, DateTime.diff(purge_after, now, :second))
  end

  defp ttl_seconds(_), do: 172_800
end