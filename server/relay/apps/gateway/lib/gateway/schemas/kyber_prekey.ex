defmodule Gateway.Schemas.KyberPrekey do
  use Ecto.Schema

  @primary_key {:user_id, :string, autogenerate: false}
  schema "kyber_prekeys" do
    field :key_id, :integer
    field :public_key, :binary
    field :signature, :binary
    field :created_at, :utc_datetime_usec
  end
end