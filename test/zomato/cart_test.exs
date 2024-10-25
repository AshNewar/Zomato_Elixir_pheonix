defmodule Zomato.CartTest do
  use Zomato.DataCase

  alias Zomato.Cart

  describe "cart_items" do
    alias Zomato.Cart.CartItem

    import Zomato.CartFixtures

    @invalid_attrs %{quantity: nil}

    test "list_cart_items/0 returns all cart_items" do
      cart_item = cart_item_fixture()
      assert Cart.list_cart_items() == [cart_item]
    end

    test "get_cart_item!/1 returns the cart_item with given id" do
      cart_item = cart_item_fixture()
      assert Cart.get_cart_item!(cart_item.id) == cart_item
    end

    test "create_cart_item/1 with valid data creates a cart_item" do
      valid_attrs = %{quantity: 42}

      assert {:ok, %CartItem{} = cart_item} = Cart.create_cart_item(valid_attrs)
      assert cart_item.quantity == 42
    end

    test "create_cart_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Cart.create_cart_item(@invalid_attrs)
    end

    test "update_cart_item/2 with valid data updates the cart_item" do
      cart_item = cart_item_fixture()
      update_attrs = %{quantity: 43}

      assert {:ok, %CartItem{} = cart_item} = Cart.update_cart_item(cart_item, update_attrs)
      assert cart_item.quantity == 43
    end

    test "update_cart_item/2 with invalid data returns error changeset" do
      cart_item = cart_item_fixture()
      assert {:error, %Ecto.Changeset{}} = Cart.update_cart_item(cart_item, @invalid_attrs)
      assert cart_item == Cart.get_cart_item!(cart_item.id)
    end

    test "delete_cart_item/1 deletes the cart_item" do
      cart_item = cart_item_fixture()
      assert {:ok, %CartItem{}} = Cart.delete_cart_item(cart_item)
      assert_raise Ecto.NoResultsError, fn -> Cart.get_cart_item!(cart_item.id) end
    end

    test "change_cart_item/1 returns a cart_item changeset" do
      cart_item = cart_item_fixture()
      assert %Ecto.Changeset{} = Cart.change_cart_item(cart_item)
    end
  end
end
