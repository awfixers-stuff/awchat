defmodule Gateway.Schemas.ChatMember do
  use Ecto.Schema

  @primary_key false
  schema "chat_members" do
    field :chat_id, :string, primary_key: true
    field :user_id, :string, primary_key: true
  end
end