defmodule Zomato.Reviews.Review do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reviews" do
    field :description, :string
    field :rate, :integer
    field :likes, :integer, default: 0
    belongs_to :restaurant, Zomato.Shops.Restraurent
    belongs_to :user, Zomato.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(review, attrs) do
    review
    |> cast(attrs, [:rate, :description, :likes, :user_id, :restaurant_id])
  end
end
