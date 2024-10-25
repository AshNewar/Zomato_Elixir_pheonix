defmodule Zomato.ReviewsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Zomato.Reviews` context.
  """

  @doc """
  Generate a review.
  """
  def review_fixture(attrs \\ %{}) do
    {:ok, review} =
      attrs
      |> Enum.into(%{
        description: "some description",
        likes: 42,
        rate: 42
      })
      |> Zomato.Reviews.create_review()

    review
  end
end
