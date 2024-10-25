defmodule Zomato.CartsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Zomato.Carts` context.
  """

  @doc """
  Generate a cart.
  """
  def cart_fixture(attrs \\ %{}) do
    {:ok, cart} =
      attrs
      |> Enum.into(%{
        status: "some status"
      })
      |> Zomato.Carts.create_cart()

    cart
  end
end
