defmodule Gateway.Schemas.Address do
  use Ecto.Schema

  @primary_key {:token, :string, autogenerate: false}
  schema "addresses" do
    field :owner_id, :string
    field :auto_accept, :boolean, default: false
    field :created_at, :utc_datetime_usec
    field :revoked_at, :utc_datetime_usec
  end
end