defmodule Zomato.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :status, Ecto.Enum, values: [:pending, :completed]
    field :total_amount, :integer
    belongs_to :user, Zomato.Accounts.User
    belongs_to :cart, Zomato.Carts.Cart
    belongs_to :restaurant, Zomato.Shops.Restraurent
    

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:status, :total_amount])
    |> validate_required([ :status, :total_amount])
  end
end
