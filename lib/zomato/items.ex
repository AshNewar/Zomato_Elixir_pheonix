defmodule Zomato.Items do
  alias Zomato.Carts
  alias Zomato.Repo
  alias Zomato.Item
  import Ecto.Query


  @doc """
  Returns the list of items.
  """
  def list_items do
    Repo.all(Item)
  end

  @doc """
  Gets a single item.
  Raises `Ecto.NoResultsError` if the Item does not exist.
  """
  def get_item!(id), do: Repo.get!(Item, id)

  def get_item_with_highest_orders do
    # Query to get the item with the highest no_of_orders
    query =
      from(i in Item,
        order_by: [desc: i.no_of_orders],
        limit: 4  # Limit to 1 item
      )

    # Execute the query
    Repo.all(query)
    |> Repo.preload(:restaurant)
  end

  @doc """
  Creates an item.
  """
  def create_item(attrs \\ %{}, restaurant_id) do
    result =
      %Item{}
      |> Item.changeset(Map.put(attrs, "restaurant_id", restaurant_id))
      |> Repo.insert()

      case result do
        {:ok, new_item} ->
          Carts.broadcast_product_event(:item_created, new_item)
          {:ok, new_item}

        error ->
          error
      end
  end


  @doc """
  Updates an item.
  """
  def update_item(id, attrs) do
    item = get_item!(id)

    result =
      item
      |> Item.changeset(attrs) # Ensure that the attrs map includes all necessary fields
      |> Repo.update()

    case result do
      {:ok, new_item} ->
        Carts.broadcast_product_event(:item_updated, new_item)
        {:ok, new_item}

      error ->
        error
    end

  end

  @doc """
  Deletes an item.
  """
 def delete_item(id) do
  case get_item!(id) do
    nil ->
      {:error, :not_found}

    item ->
      case Repo.delete(item) do
        {:ok, _} ->
          {:ok, :deleted}
        {:error, changeset} ->
          {:error, changeset}
      end
  end
end


  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.
  """
  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end

  def list_items_by_restaurant(restaurant_id) do
    query = from(i in Item, where: i.restaurant_id == ^restaurant_id)
    Repo.all(query)
  end
end
