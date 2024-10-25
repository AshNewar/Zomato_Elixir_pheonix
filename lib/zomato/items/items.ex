defmodule Zomato.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :price, :decimal
    field :name, :string
    field :description, :string
    field :photo_url, :string
    field :no_of_orders, :integer, default: 0
    field :category, :string

    # Define the relationship
    belongs_to :restaurant, Zomato.Shops.Restraurent

    timestamps()
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [:restaurant_id, :price, :name, :description, :photo_url, :no_of_orders, :category])
    |> validate_required([:restaurant_id, :price, :name])
  end
end
