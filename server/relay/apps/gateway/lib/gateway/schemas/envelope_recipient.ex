defmodule Gateway.Schemas.EnvelopeRecipient do
  use Ecto.Schema

  @primary_key false
  schema "envelope_recipients" do
    field :envelope_id, :string, primary_key: true
    field :recipient_id, :string, primary_key: true
    field :delivered_at, :utc_datetime_usec
  end
end