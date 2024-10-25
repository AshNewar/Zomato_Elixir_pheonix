defmodule ZomatoWeb.Restraurents.RestraurentForgotPasswordLiveTest do
  use ZomatoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Zomato.ShopsFixtures

  alias Zomato.Shops
  alias Zomato.Repo

  describe "Forgot password page" do
    test "renders email page", %{conn: conn} do
      {:ok, lv, html} = live(conn, ~p"/restraurents/restraurents/reset_password")

      assert html =~ "Forgot your password?"
      assert has_element?(lv, ~s|a[href="#{~p"/restraurents/restraurents/register"}"]|, "Register")
      assert has_element?(lv, ~s|a[href="#{~p"/restraurents/restraurents/log_in"}"]|, "Log in")
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_restraurent(restraurent_fixture())
        |> live(~p"/restraurents/restraurents/reset_password")
        |> follow_redirect(conn, ~p"/")

      assert {:ok, _conn} = result
    end
  end

  describe "Reset link" do
    setup do
      %{restraurent: restraurent_fixture()}
    end

    test "sends a new reset password token", %{conn: conn, restraurent: restraurent} do
      {:ok, lv, _html} = live(conn, ~p"/restraurents/restraurents/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", restraurent: %{"email" => restraurent.email})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"

      assert Repo.get_by!(Shops.RestraurentToken, restraurent_id: restraurent.id).context ==
               "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/restraurents/restraurents/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", restraurent: %{"email" => "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"
      assert Repo.all(Shops.RestraurentToken) == []
    end
  end
end
