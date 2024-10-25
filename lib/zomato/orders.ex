defmodule Zomato.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  alias Zomato.Accounts.User
  alias Zomato.Item
  alias Zomato.Cart.CartItem
  alias Zomato.Carts
  alias Zomato.Repo

  alias Zomato.Orders.Order

  @doc """
  Returns the list of orders.

  ## Examples

      iex> list_orders()
      [%Order{}, ...]

  """
  def list_orders do
    Repo.all(Order)
  end

  @doc """
  Gets a single order.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_order!(123)
      %Order{}

      iex> get_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_order!(id), do: Repo.get!(Order, id)

  @doc """
  Creates a order.

  ## Examples

      iex> create_order(%{field: value})
      {:ok, %Order{}}

      iex> create_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order(cart_id, user_id, restaurant_id, total_amount) do
    # Fetch the cart by cart_id
    case Carts.get_cart(cart_id) do
      nil ->
        {:error, "Cart not found"}

      cart ->
        # Update the cart to mark it as completed
        cart
        |> Carts.update_cart(%{status: :completed}) # Assuming you have an update_cart function
        |> case do
          {:ok, _updated_cart} ->
            %Order{
              cart_id: cart.id,
              user_id: user_id, # Assuming the cart has user_id
              restaurant_id: restaurant_id, # Assuming the cart has restaurant_id
              total_amount: total_amount, # Assuming the cart has total_amount
              status: :pending
            }
            |> Repo.insert()

          {:error, _changeset} = error ->
            error
        end
    end
  end

  def top_users_by_orders do
    from(o in Order,
      join: u in User,
      on: u.id == o.user_id,
      group_by: [o.user_id, u.name, u.profile_pic],  # Group by user-related fields
      order_by: [desc: sum(o.total_amount)],
      limit: 10,  # Get top 10 users
      select: %{
        user_id: o.user_id,
        total_amount: sum(o.total_amount),
        user_name: u.name,
        user_profile: u.profile_pic
      }
    )

    |> Repo.all()
  end


  def get_orders_summary_for_user(user_id) do
    from(o in Order,
      where: o.user_id == ^user_id,
      select: %{
        total_orders: count(o.id),
        total_amount: sum(o.total_amount)
      }
    )
    |> Repo.one()
  end

  def get_orders_for_user(user_id) do
    from(o in Order,
      where: o.user_id == ^user_id,
      order_by: [desc: o.inserted_at]  # Order by the creation time (optional)
    )
    |> Repo.all()
    |> Repo.preload(:restaurant)
  end


  def update_order_count_by_cart(cart_id) do
    cart_items =
      from(ci in CartItem, where: ci.cart_id == ^cart_id)
      |> Repo.all()

    Enum.each(cart_items, fn cart_item ->
      from(i in Item, where: i.id == ^cart_item.item_id)
      |> Repo.update_all(inc: [no_of_orders: 1])
    end)
  end



  def get_orders_by_restaurant_id_pending(restaurant_id) do
    from(o in Order,
      where: o.status == :pending and o.restaurant_id == ^restaurant_id
    )
    |> preload(:user)
    |> Repo.all()
  end


  def get_orders_by_restaurant_id_completed(restaurant_id) do
    from(o in Order,
    where: o.status == :completed and o.restaurant_id == ^restaurant_id
  )
  |> preload(:user)
  |> Repo.all()
  end


  def update_order_status_to_completed(order_id) do
    order = Repo.get!(Order, order_id)

    order
    |> Order.changeset(%{status: :completed}) # Make sure you have a changeset function in your Order schema
    |> Repo.update()
  end




  @doc """
  Updates a order.

  ## Examples

      iex> update_order(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a order.

  ## Examples

      iex> delete_order(order)
      {:ok, %Order{}}

      iex> delete_order(order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order changes.

  ## Examples

      iex> change_order(order)
      %Ecto.Changeset{data: %Order{}}

  """
  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end
end
