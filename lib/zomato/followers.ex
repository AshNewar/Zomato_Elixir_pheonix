defmodule Zomato.Followers do
  @moduledoc """
  The Followers context.
  """

  import Ecto.Query, warn: false
  alias Zomato.Repo

  alias Zomato.Followers.Follower
  alias Zomato.Accounts.User

  @doc """
  Returns the list of followers.

  ## Examples

      iex> list_followers()
      [%Follower{}, ...]

  """
  def list_followers do
    Repo.all(Follower)
  end

  @doc """
  Gets a single follower.

  Raises `Ecto.NoResultsError` if the Follower does not exist.

  ## Examples

      iex> get_follower!(123)
      %Follower{}

      iex> get_follower!(456)
      ** (Ecto.NoResultsError)

  """

  def follow_user(follower_id, followed_id) do
    %Follower{}
    |> Follower.changeset(%{follower_id: follower_id, followed_id: followed_id})
    |> Repo.insert()
  end


  def unfollow_user(follower_id, followed_id) do
    from(f in Follower, where: f.follower_id == ^follower_id and f.followed_id == ^followed_id)
    |> Repo.delete_all()
  end

  def get_user_followers(user_id) do
    Repo.all(
      from f in Follower,
      join: u in User, on: u.id == f.follower_id,
      where: f.followed_id == ^user_id,
      select: %{id: u.id, name: u.name, profile_pic: u.profile_pic}
    )
  end


  def get_user_following(user_id) do
    Repo.all(
      from f in Follower,
      join: u in User, on: u.id == f.followed_id,
      where: f.follower_id == ^user_id,
      select: %{id: u.id, name: u.name, profile_pic: u.profile_pic}
    )
  end

  def get_random_users_not_followed_by(user_id) do
    from(u in User,
      left_join: f in Follower, on: f.followed_id == u.id and f.follower_id == ^user_id,
      where: is_nil(f.id) and u.id != ^user_id,  # Exclude followed users and the current user
      order_by: fragment("RANDOM()"),
      limit: 6,
      select: %{id: u.id, name: u.name, profile_pic: u.profile_pic}
    )
    |> Repo.all()
  end




  def get_follower!(id), do: Repo.get!(Follower, id)

  @doc """
  Creates a follower.

  ## Examples

      iex> create_follower(%{field: value})
      {:ok, %Follower{}}

      iex> create_follower(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_follower(attrs \\ %{}) do
    %Follower{}
    |> Follower.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a follower.

  ## Examples

      iex> update_follower(follower, %{field: new_value})
      {:ok, %Follower{}}

      iex> update_follower(follower, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_follower(%Follower{} = follower, attrs) do
    follower
    |> Follower.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a follower.

  ## Examples

      iex> delete_follower(follower)
      {:ok, %Follower{}}

      iex> delete_follower(follower)
      {:error, %Ecto.Changeset{}}

  """
  def delete_follower(%Follower{} = follower) do
    Repo.delete(follower)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking follower changes.

  ## Examples

      iex> change_follower(follower)
      %Ecto.Changeset{data: %Follower{}}

  """
  def change_follower(%Follower{} = follower, attrs \\ %{}) do
    Follower.changeset(follower, attrs)
  end
end
