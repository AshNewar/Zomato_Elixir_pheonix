defmodule Zomato.Followers.Follower do
  use Ecto.Schema
  import Ecto.Changeset

  schema "followers" do

    field :follower_id, :id
    field :followed_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(follower, attrs) do
    follower
    |> cast(attrs, [:follower_id , :followed_id])
    |> validate_required([])
  end
end
