defmodule Zomato.FollowersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Zomato.Followers` context.
  """

  @doc """
  Generate a follower.
  """
  def follower_fixture(attrs \\ %{}) do
    {:ok, follower} =
      attrs
      |> Enum.into(%{

      })
      |> Zomato.Followers.create_follower()

    follower
  end
end
