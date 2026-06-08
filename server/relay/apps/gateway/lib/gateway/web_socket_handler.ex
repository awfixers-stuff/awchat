defmodule Gateway.WebSocketHandler do
  @moduledoc false
  @behaviour WebSock

  require Logger

  @impl true
  def init(_state) do
    challenge = Gateway.Auth.issue_ws_challenge()

    {:ok,
     %{
       authenticated: false,
       user_id: nil,
       connection_id: nil
     }, [{:push, {:text, Jason.encode!(challenge)}}]}
  end

  @impl true
  def handle_in({:text, payload}, state) do
    case Jason.decode(payload) do
      {:ok, frame} -> handle_frame(frame, state)
      {:error, _} -> close(state, 4000, "invalid_json")
    end
  end

  def handle_in(_message, state), do: {:ok, state}

  @impl true
  def handle_info({:relay_frame, frame}, state) do
    {:push, {:text, Jason.encode!(frame)}, state}
  end

  def handle_info(_message, state), do: {:ok, state}

  @impl true
  def terminate(_reason, %{user_id: user_id}) when is_binary(user_id) do
    Gateway.ConnectionRegistry.unregister(user_id)
    :ok
  end

  def terminate(_reason, _state), do: :ok

  defp handle_frame(%{"type" => "auth_response"} = frame, %{authenticated: false} = state) do
    case Gateway.Auth.verify_ws_response(frame) do
      {:ok, user_id, connection_id} ->
        Gateway.ConnectionRegistry.register(user_id, self())
        Gateway.Delivery.redeliver_pending(user_id)
        touch_last_seen(user_id)

        {:push,
         {:text,
          Jason.encode!(%{
            "type" => "auth_ok",
            "connectionId" => connection_id
          })},
         %{state | authenticated: true, user_id: user_id, connection_id: connection_id}}

      {:error, :nonce_expired} ->
        push_failed(state, "nonce_expired", 4002)

      {:error, _} ->
        push_failed(state, "auth_failed", 4001)
    end
  end

  defp handle_frame(%{"type" => "envelope"} = frame, %{authenticated: true, user_id: user_id} = state) do
    case Gateway.Delivery.handle_outbound(user_id, frame) do
      {:ok, _} -> {:ok, state}
      {:error, :forbidden} -> push_error(state, "forbidden", "Not a chat member")
      {:error, _} -> push_error(state, "invalid_frame", "Invalid envelope")
    end
  end

  defp handle_frame(%{"type" => "ack"} = frame, %{authenticated: true, user_id: user_id} = state) do
    _ = Gateway.Delivery.handle_ack(user_id, frame)
    {:ok, state}
  end

  defp handle_frame(%{"type" => "nack"} = frame, %{authenticated: true, user_id: user_id} = state) do
    _ = Gateway.Delivery.handle_nack(user_id, frame)
    {:ok, state}
  end

  defp handle_frame(_frame, %{authenticated: false}), do: close(%{authenticated: false}, 4001, "auth_required")

  defp handle_frame(_frame, state), do: {:ok, state}

  defp push_failed(state, code, close_code) do
    frame = %{
      "type" => "auth_failed",
      "code" => code,
      "message" => "Authentication failed"
    }

    {:stop, close_code, {:push, {:text, Jason.encode!(frame)}, state}}
  end

  defp push_error(state, code, message) do
    frame = %{"type" => "error", "code" => code, "message" => message}
    {:push, {:text, Jason.encode!(frame)}, state}
  end

  defp close(state, code, reason) do
    {:stop, {code, reason}, state}
  end

  defp touch_last_seen(user_id) do
    import Ecto.Query

    now = Gateway.Time.now()

    Gateway.Repo.update_all(
      from(u in Gateway.Schemas.User, where: u.id == ^user_id),
      set: [last_seen_at: now]
    )
  end
end