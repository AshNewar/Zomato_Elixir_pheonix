defmodule Zomato.Message do
  alias Zomato.Repo
  alias Phoenix.PubSub
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias __MODULE__

  schema "messages" do
    field :message, :string
    field :room_id, :integer
    belongs_to :user, Zomato.Accounts.User


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:user_id, :message, :room_id])
    |> validate_required([:user_id, :message, :room_id])
    |> validate_length(:message, min: 2)
  end

  def create_message(attrs) do
    %Message{}
    |> changeset(attrs)
    |> Repo.insert()
    |> notify(:message_created)
  end

  def list_messages(room_id) do
    Message
    |> where([m], m.room_id == ^room_id)
    |> preload(:user)
    |> limit(50)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end


  def subscribe() do
    PubSub.subscribe(Zomato.PubSub, "zomato_chat")
  end

  def notify({:ok, message}, event) do
    PubSub.broadcast(Zomato.PubSub, "zomato_chat", {event, message})
  end

  def notify({:error, reason}, _event), do: {:error, reason}
end
