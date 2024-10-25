defmodule Zomato.Reviews do
  @moduledoc """
  The Reviews context.
  """

  import Ecto.Query, warn: false
  alias Zomato.Repo

  alias Zomato.Reviews.Review

  @doc """
  Returns the list of reviews.

  ## Examples

      iex> list_reviews()
      [%Review{}, ...]

  """
  def list_reviews do
    Repo.all(Review)
  end

  @doc """
  Gets a single review.

  Raises `Ecto.NoResultsError` if the Review does not exist.

  ## Examples

      iex> get_review!(123)
      %Review{}

      iex> get_review!(456)
      ** (Ecto.NoResultsError)

  """
  def get_review!(id), do: Repo.get!(Review, id)

  def get_review_summary_user(user_id) do
    from(o in Review,
      where: o.user_id == ^user_id,
      select: %{
        total_reviews: count(o.id),
      }
    )
    |> Repo.one()
  end

  @doc """
  Creates a review.

  ## Examples

      iex> create_review(%{field: value})
      {:ok, %Review{}}

      iex> create_review(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_review(attrs \\ %{}, user_id, restaurant_id) do
    %Review{}
    |> Review.changeset(Map.put(attrs, "user_id", user_id))
    |> Review.changeset(Map.put(attrs, "restaurant_id", restaurant_id))
    |> Repo.insert()
  end

  def get_review_user_id(user_id) do
    query = from(r in Review,
                 where: r.user_id == ^user_id,
                 preload: [:user])  # Preload the associated user data

    Repo.all(query)
  end

  def get_review_restaurant_id(restaurant_id) do
    query = from(r in Review,
                 where: r.restaurant_id == ^restaurant_id,
                 preload: [:user])  # Preload the associated restaurant data

    Repo.all(query)
  end




  @doc """
  Updates a review.

  ## Examples

      iex> update_review(review, %{field: new_value})
      {:ok, %Review{}}

      iex> update_review(review, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_review(%Review{} = review, attrs) do
    review
    |> Review.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a review.

  ## Examples

      iex> delete_review(review)
      {:ok, %Review{}}

      iex> delete_review(review)
      {:error, %Ecto.Changeset{}}

  """
  def delete_review(%Review{} = review) do
    Repo.delete(review)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking review changes.

  ## Examples

      iex> change_review(review)
      %Ecto.Changeset{data: %Review{}}

  """
  def change_review(%Review{} = review, attrs \\ %{}) do
    Review.changeset(review, attrs)
  end
end
