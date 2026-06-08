defmodule Gateway.Repo.Migrations.InitSchema do
  use Ecto.Migration

  def change do
    create table(:identities, primary_key: false) do
      add :id, :text, primary_key: true
      add :identity_key, :binary, null: false
      add :created_at, :utc_datetime_usec, null: false, default: fragment("NOW()")
    end

    create table(:invites, primary_key: false) do
      add :token, :text, primary_key: true
      add :owner_id, references(:identities, type: :text, on_delete: :delete_all), null: false
      add :auto_accept, :boolean, null: false, default: false
      add :created_at, :utc_datetime_usec, null: false, default: fragment("NOW()")
      add :consumed_at, :utc_datetime_usec
    end

    create index(:invites, [:owner_id])

    create table(:addresses, primary_key: false) do
      add :token, :text, primary_key: true
      add :owner_id, references(:identities, type: :text, on_delete: :delete_all), null: false
      add :auto_accept, :boolean, null: false, default: false
      add :created_at, :utc_datetime_usec, null: false, default: fragment("NOW()")
      add :revoked_at, :utc_datetime_usec
    end

    create index(:addresses, [:owner_id])

    create table(:connection_requests, primary_key: false) do
      add :id, :text, primary_key: true
      add :recipient_id, references(:identities, type: :text, on_delete: :delete_all), null: false
      add :requester_id, references(:identities, type: :text, on_delete: :delete_all), null: false
      add :display_name, :text, null: false
      add :source_type, :text, null: false
      add :source_token, :text, null: false
      add :status, :text, null: false, default: "pending"
      add :created_at, :utc_datetime_usec, null: false, default: fragment("NOW()")
      add :responded_at, :utc_datetime_usec
    end

    create constraint(:connection_requests, :source_type_check,
      check: "source_type IN ('invite', 'address')"
    )

    create constraint(:connection_requests, :status_check,
      check: "status IN ('pending', 'accepted', 'rejected')"
    )

    create index(:connection_requests, [:recipient_id, :status])
    create index(:connection_requests, [:requester_id])
  end
end