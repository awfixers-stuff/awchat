defmodule Gateway.Schemas.User do
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}
  schema "users" do
    field :identity_key, :binary
    field :registration_id, :integer, default: 0
    field :created_at, :utc_datetime_usec
    field :last_seen_at, :utc_datetime_usec
  end
end