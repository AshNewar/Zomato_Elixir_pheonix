defmodule ZomatoWeb.Restraurents.RestraurentSessionControllerTest do
  use ZomatoWeb.ConnCase, async: true

  import Zomato.ShopsFixtures

  setup do
    %{restraurent: restraurent_fixture()}
  end

  describe "POST /restraurents/restraurents/log_in" do
    test "logs the restraurent in", %{conn: conn, restraurent: restraurent} do
      conn =
        post(conn, ~p"/restraurents/restraurents/log_in", %{
          "restraurent" => %{"email" => restraurent.email, "password" => valid_restraurent_password()}
        })

      assert get_session(conn, :restraurent_token)
      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ restraurent.email
      assert response =~ ~p"/restraurents/restraurents/settings"
      assert response =~ ~p"/restraurents/restraurents/log_out"
    end

    test "logs the restraurent in with remember me", %{conn: conn, restraurent: restraurent} do
      conn =
        post(conn, ~p"/restraurents/restraurents/log_in", %{
          "restraurent" => %{
            "email" => restraurent.email,
            "password" => valid_restraurent_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_zomato_web_restraurent_remember_me"]
      assert redirected_to(conn) == ~p"/"
    end

    test "logs the restraurent in with return to", %{conn: conn, restraurent: restraurent} do
      conn =
        conn
        |> init_test_session(restraurent_return_to: "/foo/bar")
        |> post(~p"/restraurents/restraurents/log_in", %{
          "restraurent" => %{
            "email" => restraurent.email,
            "password" => valid_restraurent_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "login following registration", %{conn: conn, restraurent: restraurent} do
      conn =
        conn
        |> post(~p"/restraurents/restraurents/log_in", %{
          "_action" => "registered",
          "restraurent" => %{
            "email" => restraurent.email,
            "password" => valid_restraurent_password()
          }
        })

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Account created successfully"
    end

    test "login following password update", %{conn: conn, restraurent: restraurent} do
      conn =
        conn
        |> post(~p"/restraurents/restraurents/log_in", %{
          "_action" => "password_updated",
          "restraurent" => %{
            "email" => restraurent.email,
            "password" => valid_restraurent_password()
          }
        })

      assert redirected_to(conn) == ~p"/restraurents/restraurents/settings"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Password updated successfully"
    end

    test "redirects to login page with invalid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/restraurents/restraurents/log_in", %{
          "restraurent" => %{"email" => "invalid@email.com", "password" => "invalid_password"}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
      assert redirected_to(conn) == ~p"/restraurents/restraurents/log_in"
    end
  end

  describe "DELETE /restraurents/restraurents/log_out" do
    test "logs the restraurent out", %{conn: conn, restraurent: restraurent} do
      conn = conn |> log_in_restraurent(restraurent) |> delete(~p"/restraurents/restraurents/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :restraurent_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the restraurent is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/restraurents/restraurents/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :restraurent_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end
