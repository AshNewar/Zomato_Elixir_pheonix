defmodule Zomato.Gallery.Photo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "photos" do
    field :url, :string
    field :user_done, :boolean, default: false
    belongs_to :restaurant, Zomato.Shops.Restraurent
    belongs_to :user, Zomato.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:url, :user_id, :restaurant_id, :user_done])
  end
end
