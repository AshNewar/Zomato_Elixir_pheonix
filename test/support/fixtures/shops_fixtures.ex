defmodule Zomato.ShopsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Zomato.Shops` context.
  """

  def unique_restraurent_email, do: "restraurent#{System.unique_integer()}@example.com"
  def valid_restraurent_password, do: "hello world!"

  def valid_restraurent_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_restraurent_email(),
      password: valid_restraurent_password()
    })
  end

  def restraurent_fixture(attrs \\ %{}) do
    {:ok, restraurent} =
      attrs
      |> valid_restraurent_attributes()
      |> Zomato.Shops.register_restraurent()

    restraurent
  end

  def extract_restraurent_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
