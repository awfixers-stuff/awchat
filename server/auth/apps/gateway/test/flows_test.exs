defmodule Gateway.FlowsTest do
  use Gateway.DataCase, async: false

  @moduletag :integration

  setup_all do
    {:ok, _} = Application.ensure_all_started(:gateway)
    :ok
  end

  alias Gateway.Repo
  alias Gateway.Schemas.{Address, ConnectionRequest, Identity, Invite}

  setup do
    now = Gateway.Time.now()

    owner =
      %Identity{}
      |> Ecto.Changeset.change(%{
        id: "awchat:OWNER111",
        identity_key: :crypto.strong_rand_bytes(33),
        created_at: now
      })
      |> Repo.insert!()

    requester =
      %Identity{}
      |> Ecto.Changeset.change(%{
        id: "awchat:REQ22222",
        identity_key: :crypto.strong_rand_bytes(33),
        created_at: now
      })
      |> Repo.insert!()

    %{owner: owner, requester: requester}
  end

  test "one-time invite flow", %{owner: owner, requester: requester} do
    {:ok, invite} = Gateway.Invites.create(owner.id, %{})
    assert invite["uri"] == "awchat://i/#{invite["token"]}"

    {:ok, resolved} = Gateway.Invites.resolve(invite["token"])
    assert resolved["valid"] == true

    {:ok, request} =
      Gateway.Invites.submit_request(invite["token"], requester.id, %{"displayName" => "Bob"})

    assert request["status"] == "pending"
    assert request["displayName"] == "Bob"
    assert request["recipientUserId"] == owner.id
    assert request["requesterUserId"] == requester.id

    assert {:error, :consumed} = Gateway.Invites.resolve(invite["token"])

    consumed = Repo.get!(Invite, invite["token"])
    assert consumed.consumed_at != nil
  end

  test "invite auto-accept", %{owner: owner, requester: requester} do
    {:ok, invite} = Gateway.Invites.create(owner.id, %{"autoAccept" => true})

    {:ok, request} =
      Gateway.Invites.submit_request(invite["token"], requester.id, %{"displayName" => "Auto"})

    assert request["status"] == "accepted"
    assert request["respondedAt"] != nil
  end

  test "long-term address flow", %{owner: owner, requester: requester} do
    {:ok, address} = Gateway.Addresses.create(owner.id, %{})
    assert address["uri"] == "awchat://a/#{address["token"]}"

    {:ok, resolved} = Gateway.Addresses.resolve(address["token"])
    assert resolved["valid"] == true

    {:ok, request} =
      Gateway.Addresses.submit_request(address["token"], requester.id, %{"displayName" => "Carol"})

    assert request["status"] == "pending"

    {:ok, _} =
      Gateway.Addresses.submit_request(address["token"], requester.id, %{"displayName" => "Dave"})

    assert Repo.aggregate(ConnectionRequest, :count) == 2

    assert :ok = Gateway.Addresses.revoke(address["token"], owner.id)
    assert {:error, :revoked} = Gateway.Addresses.resolve(address["token"])

    revoked = Repo.get!(Address, address["token"])
    assert revoked.revoked_at != nil
  end

  test "connection request accept and reject", %{owner: owner, requester: requester} do
    {:ok, address} = Gateway.Addresses.create(owner.id, %{})

    {:ok, to_accept} =
      Gateway.Addresses.submit_request(address["token"], requester.id, %{"displayName" => "Eve"})

    {:ok, to_reject} =
      Gateway.Addresses.submit_request(address["token"], requester.id, %{"displayName" => "Frank"})

    {:ok, %{"requests" => pending}} = Gateway.ConnectionRequests.list_pending(owner.id)
    assert length(pending) == 2

    {:ok, accepted} =
      Gateway.ConnectionRequests.respond(owner.id, to_accept["id"], %{"action" => "accept"})

    assert accepted["status"] == "accepted"

    {:ok, rejected} =
      Gateway.ConnectionRequests.respond(owner.id, to_reject["id"], %{"action" => "reject"})

    assert rejected["status"] == "rejected"
  end

  test "self request is rejected", %{owner: owner} do
    {:ok, invite} = Gateway.Invites.create(owner.id, %{})
    assert {:error, :self_request} = Gateway.Invites.submit_request(invite["token"], owner.id, %{"displayName" => "Me"})
  end
end