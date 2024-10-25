defmodule Zomato.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Zomato.Orders` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, order} =
      attrs
      |> Enum.into(%{
        mode_of_payment: "some mode_of_payment",
        status: "some status",
        total_amount: 42
      })
      |> Zomato.Orders.create_order()

    order
  end
end
