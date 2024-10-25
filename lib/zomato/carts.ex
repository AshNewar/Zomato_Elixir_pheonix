defmodule Zomato.Carts do
  @moduledoc """
  The Carts context.
  """

  import Ecto.Query, warn: false
  alias Zomato.Cart.CartItem
  alias Zomato.Repo

  alias Zomato.Carts.Cart

  @doc """
  Returns the list of carts.

  ## Examples

      iex> list_carts()
      [%Cart{}, ...]

  """
  def list_carts do
    Repo.all(Cart)
  end

  @doc """
  Gets a single cart.

  Raises `Ecto.NoResultsError` if the Cart does not exist.

  ## Examples

      iex> get_cart!(123)
      %Cart{}

      iex> get_cart!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cart(id) do
    Repo.get(Cart, id)
  end

  @doc """
  Creates a cart.

  ## Examples

      iex> create_cart(%{field: value})
      {:ok, %Cart{}}

      iex> create_cart(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cart do
    Repo.insert(%Cart{status: :open})
  end


  def list_cart_items(cart_id) do
    CartItem
    |> where([ci], ci.cart_id == ^cart_id)
    |> preload(:item)
    |> Repo.all()
  end


  def add_item_to_cart(cart_id, item_id, user_id, restaurant_id) do
    existing_cart_item =
      from(ci in CartItem,
        where: ci.cart_id == ^cart_id and ci.item_id == ^item_id
      )
      |> Repo.one()

    case existing_cart_item do
      %CartItem{} = cart_item ->
        cart_item
        |> Ecto.Changeset.change(%{quantity: cart_item.quantity + 1})
        |> Repo.update()

      nil ->
        Repo.insert(%CartItem{
          cart_id: cart_id,
          item_id: item_id,
          user_id: user_id,
          restaurant_id: restaurant_id,
        })
    end
  end


  @doc """
  Updates a cart.

  ## Examples

      iex> update_cart(cart, %{field: new_value})
      {:ok, %Cart{}}

      iex> update_cart(cart, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cart(%Cart{} = cart, attrs) do
    cart
    |> Cart.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cart.

  ## Examples

      iex> delete_cart(cart)
      {:ok, %Cart{}}

      iex> delete_cart(cart)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cart(%Cart{} = cart) do
    Repo.delete(cart)
  end

  def delete_cart_id(id) do
    cart = get_cart(id)
    Repo.delete(cart)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cart changes.

  ## Examples

      iex> change_cart(cart)
      %Ecto.Changeset{data: %Cart{}}

  """
  def change_cart(%Cart{} = cart, attrs \\ %{}) do
    Cart.changeset(cart, attrs)
  end

  def subscribe_to_product_events do
    Phoenix.PubSub.subscribe(Zomato.PubSub, "items")
  end

  def broadcast_product_event(event, item) do
    Phoenix.PubSub.broadcast(Zomato.PubSub, "items", {event, item})
  end

end
