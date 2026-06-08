defmodule Gateway.Jobs do
  @moduledoc false
  import Ecto.Query

  alias Gateway.Repo
  alias Gateway.Schemas.{AuthNonce, MessageEnvelope, Prekey}

  @spec purge_expired_envelopes() :: :ok
  def purge_expired_envelopes do
    cutoff = DateTime.add(Gateway.Time.now(), -48, :hour)
    now = Gateway.Time.now()

    from(e in MessageEnvelope,
      where: e.created_at < ^cutoff or e.purge_after < ^now
    )
    |> Repo.delete_all()

    :ok
  end

  @spec purge_expired_nonces() :: :ok
  def purge_expired_nonces do
    now = Gateway.Time.now()

    from(n in AuthNonce, where: n.expires_at < ^now)
    |> Repo.delete_all()

    :ok
  end

  @spec purge_stale_prekeys() :: :ok
  def purge_stale_prekeys do
    cutoff = DateTime.add(Gateway.Time.now(), -24, :hour)

    from(p in Prekey,
      where: p.consumed == false and p.inserted_at < ^cutoff
    )
    |> Repo.delete_all()

    :ok
  end
end