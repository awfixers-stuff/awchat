defmodule Gateway.Schemas.Prekey do
  use Ecto.Schema

  @primary_key false
  schema "prekeys" do
    field :user_id, :string, primary_key: true
    field :key_id, :integer, primary_key: true
    field :public_key, :binary
    field :consumed, :boolean, default: false
    field :inserted_at, :utc_datetime_usec
  end
end