defmodule Zomato.Cart.CartItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cart_items" do
    field :quantity, :integer, default: 1
    belongs_to :user, Zomato.Accounts.User  # Assuming you have an Accounts context
    belongs_to :item, Zomato.Item    # Assuming you have an Items context
    belongs_to :cart, Zomato.Carts.Cart
    belongs_to :restaurant, Zomato.Shops.Restraurent


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cart_item, attrs) do
    cart_item
    |> cast(attrs, [:quantity, :item_id, :user_id, :restaurant_id])
    |> validate_required([:quantity])
  end
end
