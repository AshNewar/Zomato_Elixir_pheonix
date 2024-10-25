defmodule ZomatoWeb.Restraurents.RestraurentConfirmationInstructionsLiveTest do
  use ZomatoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Zomato.ShopsFixtures

  alias Zomato.Shops
  alias Zomato.Repo

  setup do
    %{restraurent: restraurent_fixture()}
  end

  describe "Resend confirmation" do
    test "renders the resend confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/restraurents/restraurents/confirm")
      assert html =~ "Resend confirmation instructions"
    end

    test "sends a new confirmation token", %{conn: conn, restraurent: restraurent} do
      {:ok, lv, _html} = live(conn, ~p"/restraurents/restraurents/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", restraurent: %{email: restraurent.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.get_by!(Shops.RestraurentToken, restraurent_id: restraurent.id).context == "confirm"
    end

    test "does not send confirmation token if restraurent is confirmed", %{conn: conn, restraurent: restraurent} do
      Repo.update!(Shops.Restraurent.confirm_changeset(restraurent))

      {:ok, lv, _html} = live(conn, ~p"/restraurents/restraurents/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", restraurent: %{email: restraurent.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      refute Repo.get_by(Shops.RestraurentToken, restraurent_id: restraurent.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/restraurents/restraurents/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", restraurent: %{email: "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.all(Shops.RestraurentToken) == []
    end
  end
end
