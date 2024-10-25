defmodule ZomatoWeb.Restraurents.RestraurentSettingsLiveTest do
  use ZomatoWeb.ConnCase, async: true

  alias Zomato.Shops
  import Phoenix.LiveViewTest
  import Zomato.ShopsFixtures

  describe "Settings page" do
    test "renders settings page", %{conn: conn} do
      {:ok, _lv, html} =
        conn
        |> log_in_restraurent(restraurent_fixture())
        |> live(~p"/restraurents/restraurents/settings")

      assert html =~ "Change Email"
      assert html =~ "Change Password"
    end

    test "redirects if restraurent is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/restraurents/restraurents/settings")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/restraurents/restraurents/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end

  describe "update email form" do
    setup %{conn: conn} do
      password = valid_restraurent_password()
      restraurent = restraurent_fixture(%{password: password})
      %{conn: log_in_restraurent(conn, restraurent), restraurent: restraurent, password: password}
    end

    test "updates the restraurent email", %{conn: conn, password: password, restraurent: restraurent} do
      new_email = unique_restraurent_email()

      {:ok, lv, _html} = live(conn, ~p"/restraurents/restraurents/settings")

      result =
        lv
        |> form("#email_form", %{
          "current_password" => password,
          "restraurent" => %{"email" => new_email}
        })
        |> render_submit()

      assert result =~ "A link to confirm your email"
      assert Shops.get_restraurent_by_email(restraurent.email)
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/restraurents/restraurents/settings")

      result =
        lv
        |> element("#email_form")
        |> render_change(%{
          "action" => "update_email",
          "current_password" => "invalid",
          "restraurent" => %{"email" => "with spaces"}
        })

      assert result =~ "Change Email"
      assert result =~ "must have the @ sign and no spaces"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn, restraurent: restraurent} do
      {:ok, lv, _html} = live(conn, ~p"/restraurents/restraurents/settings")

      result =
        lv
        |> form("#email_form", %{
          "current_password" => "invalid",
          "restraurent" => %{"email" => restraurent.email}
        })
        |> render_submit()

      assert result =~ "Change Email"
      assert result =~ "did not change"
      assert result =~ "is not valid"
    end
  end

  describe "update password form" do
    setup %{conn: conn} do
      password = valid_restraurent_password()
      restraurent = restraurent_fixture(%{password: password})
      %{conn: log_in_restraurent(conn, restraurent), restraurent: restraurent, password: password}
    end

    test "updates the restraurent password", %{conn: conn, restraurent: restraurent, password: password} do
      new_password = valid_restraurent_password()

      {:ok, lv, _html} = live(conn, ~p"/restraurents/restraurents/settings")

      form =
        form(lv, "#password_form", %{
          "current_password" => password,
          "restraurent" => %{
            "email" => restraurent.email,
            "password" => new_password,
            "password_confirmation" => new_password
          }
        })

      render_submit(form)

      new_password_conn = follow_trigger_action(form, conn)

      assert redirected_to(new_password_conn) == ~p"/restraurents/restraurents/settings"

      assert get_session(new_password_conn, :restraurent_token) != get_session(conn, :restraurent_token)

      assert Phoenix.Flash.get(new_password_conn.assigns.flash, :info) =~
               "Password updated successfully"

      assert Shops.get_restraurent_by_email_and_password(restraurent.email, new_password)
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/restraurents/restraurents/settings")

      result =
        lv
        |> element("#password_form")
        |> render_change(%{
          "current_password" => "invalid",
          "restraurent" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      assert result =~ "Change Password"
      assert result =~ "should be at least 12 character(s)"
      assert result =~ "does not match password"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/restraurents/restraurents/settings")

      result =
        lv
        |> form("#password_form", %{
          "current_password" => "invalid",
          "restraurent" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })
        |> render_submit()

      assert result =~ "Change Password"
      assert result =~ "should be at least 12 character(s)"
      assert result =~ "does not match password"
      assert result =~ "is not valid"
    end
  end

  describe "confirm email" do
    setup %{conn: conn} do
      restraurent = restraurent_fixture()
      email = unique_restraurent_email()

      token =
        extract_restraurent_token(fn url ->
          Shops.deliver_restraurent_update_email_instructions(%{restraurent | email: email}, restraurent.email, url)
        end)

      %{conn: log_in_restraurent(conn, restraurent), token: token, email: email, restraurent: restraurent}
    end

    test "updates the restraurent email once", %{conn: conn, restraurent: restraurent, token: token, email: email} do
      {:error, redirect} = live(conn, ~p"/restraurents/restraurents/settings/confirm_email/#{token}")

      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/restraurents/restraurents/settings"
      assert %{"info" => message} = flash
      assert message == "Email changed successfully."
      refute Shops.get_restraurent_by_email(restraurent.email)
      assert Shops.get_restraurent_by_email(email)

      # use confirm token again
      {:error, redirect} = live(conn, ~p"/restraurents/restraurents/settings/confirm_email/#{token}")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/restraurents/restraurents/settings"
      assert %{"error" => message} = flash
      assert message == "Email change link is invalid or it has expired."
    end

    test "does not update email with invalid token", %{conn: conn, restraurent: restraurent} do
      {:error, redirect} = live(conn, ~p"/restraurents/restraurents/settings/confirm_email/oops")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/restraurents/restraurents/settings"
      assert %{"error" => message} = flash
      assert message == "Email change link is invalid or it has expired."
      assert Shops.get_restraurent_by_email(restraurent.email)
    end

    test "redirects if restraurent is not logged in", %{token: token} do
      conn = build_conn()
      {:error, redirect} = live(conn, ~p"/restraurents/restraurents/settings/confirm_email/#{token}")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/restraurents/restraurents/log_in"
      assert %{"error" => message} = flash
      assert message == "You must log in to access this page."
    end
  end
end
