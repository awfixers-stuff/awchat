defmodule Gateway.Schemas.AuthNonce do
  use Ecto.Schema

  @primary_key {:nonce, :binary, autogenerate: false}
  schema "auth_nonces" do
    field :created_at, :utc_datetime_usec
    field :expires_at, :utc_datetime_usec
  end
end