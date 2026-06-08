defmodule Gateway.Schemas.PurgeAudit do
  use Ecto.Schema

  @primary_key {:message_id, :string, autogenerate: false}
  schema "purge_audit" do
    field :chat_id, :string
    field :requested_by, :string
    field :purge_received_at, :utc_datetime_usec
  end
end