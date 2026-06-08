defmodule Gateway.Schemas.Invite do
  use Ecto.Schema

  @primary_key {:token, :string, autogenerate: false}
  schema "invites" do
    field :owner_id, :string
    field :auto_accept, :boolean, default: false
    field :created_at, :utc_datetime_usec
    field :consumed_at, :utc_datetime_usec
  end
end