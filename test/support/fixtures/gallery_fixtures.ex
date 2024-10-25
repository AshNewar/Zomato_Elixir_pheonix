defmodule Zomato.GalleryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Zomato.Gallery` context.
  """

  @doc """
  Generate a photo.
  """
  def photo_fixture(attrs \\ %{}) do
    {:ok, photo} =
      attrs
      |> Enum.into(%{
        url: "some url"
      })
      |> Zomato.Gallery.create_photo()

    photo
  end
end
