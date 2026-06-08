defmodule Gateway.Schemas.ConnectionRequest do
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}
  schema "connection_requests" do
    field :recipient_id, :string
    field :requester_id, :string
    field :display_name, :string
    field :source_type, :string
    field :source_token, :string
    field :status, :string, default: "pending"
    field :created_at, :utc_datetime_usec
    field :responded_at, :utc_datetime_usec
  end
end