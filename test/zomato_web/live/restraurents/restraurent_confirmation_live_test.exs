defmodule ZomatoWeb.Restraurents.RestraurentConfirmationLiveTest do
  use ZomatoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Zomato.ShopsFixtures

  alias Zomato.Shops
  alias Zomato.Repo

  setup do
    %{restraurent: restraurent_fixture()}
  end

  describe "Confirm restraurent" do
    test "renders confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/restraurents/restraurents/confirm/some-token")
      assert html =~ "Confirm Account"
    end

    test "confirms the given token once", %{conn: conn, restraurent: restraurent} do
      token =
        extract_restraurent_token(fn url ->
          Shops.deliver_restraurent_confirmation_instructions(restraurent, url)
        end)

      {:ok, lv, _html} = live(conn, ~p"/restraurents/restraurents/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Restraurent confirmed successfully"

      assert Shops.get_restraurent!(restraurent.id).confirmed_at
      refute get_session(conn, :restraurent_token)
      assert Repo.all(Shops.RestraurentToken) == []

      # when not logged in
      {:ok, lv, _html} = live(conn, ~p"/restraurents/restraurents/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Restraurent confirmation link is invalid or it has expired"

      # when logged in
      conn =
        build_conn()
        |> log_in_restraurent(restraurent)

      {:ok, lv, _html} = live(conn, ~p"/restraurents/restraurents/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result
      refute Phoenix.Flash.get(conn.assigns.flash, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, restraurent: restraurent} do
      {:ok, lv, _html} = live(conn, ~p"/restraurents/restraurents/confirm/invalid-token")

      {:ok, conn} =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Restraurent confirmation link is invalid or it has expired"

      refute Shops.get_restraurent!(restraurent.id).confirmed_at
    end
  end
end
