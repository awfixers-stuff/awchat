defmodule Gateway.Schemas.MessageEnvelope do
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}
  schema "message_envelopes" do
    field :chat_id, :string
    field :sender_id, :string
    field :ciphertext, :binary
    field :created_at, :utc_datetime_usec
    field :purge_after, :utc_datetime_usec
  end
end