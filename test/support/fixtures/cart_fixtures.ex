defmodule Zomato.CartFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Zomato.Cart` context.
  """

  @doc """
  Generate a cart_item.
  """
  def cart_item_fixture(attrs \\ %{}) do
    {:ok, cart_item} =
      attrs
      |> Enum.into(%{
        quantity: 42
      })
      |> Zomato.Cart.create_cart_item()

    cart_item
  end
end
