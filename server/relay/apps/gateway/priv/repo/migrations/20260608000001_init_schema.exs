defmodule Gateway.Repo.Migrations.InitSchema do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :text, primary_key: true
      add :identity_key, :binary, null: false
      add :registration_id, :integer, null: false, default: 0
      add :created_at, :utc_datetime_usec, null: false, default: fragment("NOW()")
      add :last_seen_at, :utc_datetime_usec
    end

    create table(:signed_prekeys, primary_key: false) do
      add :user_id, references(:users, type: :text, on_delete: :delete_all),
        primary_key: true

      add :key_id, :integer, null: false
      add :public_key, :binary, null: false
      add :signature, :binary, null: false
      add :created_at, :utc_datetime_usec, null: false, default: fragment("NOW()")
    end

    create table(:kyber_prekeys, primary_key: false) do
      add :user_id, references(:users, type: :text, on_delete: :delete_all),
        primary_key: true

      add :key_id, :integer, null: false
      add :public_key, :binary, null: false
      add :signature, :binary, null: false
      add :created_at, :utc_datetime_usec, null: false, default: fragment("NOW()")
    end

    create table(:prekeys, primary_key: false) do
      add :user_id, references(:users, type: :text, on_delete: :delete_all), primary_key: true
      add :key_id, :integer, primary_key: true
      add :public_key, :binary, null: false
      add :consumed, :boolean, default: false

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create table(:chats, primary_key: false) do
      add :id, :text, primary_key: true
      add :type, :text, null: false
      add :created_at, :utc_datetime_usec, null: false, default: fragment("NOW()")
    end

    create constraint(:chats, :type_check, check: "type IN ('direct', 'group')")

    create table(:chat_members, primary_key: false) do
      add :chat_id, references(:chats, type: :text, on_delete: :delete_all), primary_key: true
      add :user_id, references(:users, type: :text, on_delete: :delete_all), primary_key: true
    end

    create table(:message_envelopes, primary_key: false) do
      add :id, :text, primary_key: true
      add :chat_id, references(:chats, type: :text, on_delete: :delete_all)
      add :sender_id, references(:users, type: :text, on_delete: :delete_all)
      add :ciphertext, :binary, null: false
      add :created_at, :utc_datetime_usec, null: false, default: fragment("NOW()")
      add :purge_after, :utc_datetime_usec, null: false
    end

    create index(:message_envelopes, [:chat_id])
    create index(:message_envelopes, [:created_at])
    create index(:message_envelopes, [:purge_after])

    create table(:envelope_recipients, primary_key: false) do
      add :envelope_id,
          references(:message_envelopes, type: :text, on_delete: :delete_all),
          primary_key: true

      add :recipient_id, references(:users, type: :text, on_delete: :delete_all), primary_key: true
      add :delivered_at, :utc_datetime_usec
    end
    create index(:envelope_recipients, [:recipient_id])

    create table(:auth_nonces, primary_key: false) do
      add :nonce, :binary, primary_key: true
      add :created_at, :utc_datetime_usec, null: false, default: fragment("NOW()")
      add :expires_at, :utc_datetime_usec, null: false
    end

    create index(:auth_nonces, [:expires_at])

    create table(:purge_audit, primary_key: false) do
      add :message_id, :text, primary_key: true
      add :chat_id, :text, null: false
      add :requested_by, :text, null: false
      add :purge_received_at, :utc_datetime_usec, null: false, default: fragment("NOW()")
    end
  end
end