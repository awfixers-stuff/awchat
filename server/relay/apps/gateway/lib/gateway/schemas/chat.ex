defmodule Gateway.Schemas.Chat do
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}
  schema "chats" do
    field :type, :string
    field :created_at, :utc_datetime_usec
  end
end