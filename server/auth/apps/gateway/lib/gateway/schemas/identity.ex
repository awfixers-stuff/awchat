defmodule Gateway.Schemas.Identity do
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}
  schema "identities" do
    field :identity_key, :binary
    field :created_at, :utc_datetime_usec
  end
end