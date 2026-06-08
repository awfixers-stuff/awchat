defmodule Broker.RateLimiter do
  @moduledoc false

  @spec hit(String.t(), non_neg_integer(), non_neg_integer()) ::
          {:allow, non_neg_integer()} | {:deny, non_neg_integer()}
  def hit(key, window_ms, limit) do
    if Broker.Redis.enabled?() do
      Broker.RateLimiter.Redis.hit(key, window_ms, limit)
    else
      Broker.RateLimiter.Ets.hit(key, window_ms, limit)
    end
  end
end

defmodule Broker.RateLimiter.Ets do
  @moduledoc false
  use Hammer, backend: :ets
end

defmodule Broker.RateLimiter.Redis do
  @moduledoc false
  @prefix "awchat:v1:broker:rl:"

  @spec hit(String.t(), non_neg_integer(), non_neg_integer()) ::
          {:allow, non_neg_integer()} | {:deny, non_neg_integer()}
  def hit(key, window_ms, limit) do
    redis_key = @prefix <> key

    case Broker.Redis.command(["INCR", redis_key]) do
      {:ok, count} when is_integer(count) and count <= limit ->
        if count == 1 do
          _ = Broker.Redis.command(["PEXPIRE", redis_key, Integer.to_string(window_ms)])
        end

        {:allow, count}

      {:ok, count} when is_integer(count) ->
        {:deny, window_ms}

      {:error, _} ->
        # Fail open on Redis errors so edge stays available; Postgres still holds ciphertext.
        {:allow, 0}
    end
  end
end