defmodule ZomatoWeb.Restraurents.RestraurentAuthTest do
  use ZomatoWeb.ConnCase, async: true

  alias Phoenix.LiveView
  alias Zomato.Shops
  alias ZomatoWeb.Restraurents.RestraurentAuth
  import Zomato.ShopsFixtures

  @remember_me_cookie "_zomato_web_restraurent_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, ZomatoWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{restraurent: restraurent_fixture(), conn: conn}
  end

  describe "log_in_restraurent/3" do
    test "stores the restraurent token in the session", %{conn: conn, restraurent: restraurent} do
      conn = RestraurentAuth.log_in_restraurent(conn, restraurent)
      assert token = get_session(conn, :restraurent_token)
      assert get_session(conn, :live_socket_id) == "restraurents_sessions:#{Base.url_encode64(token)}"
      assert redirected_to(conn) == ~p"/"
      assert Shops.get_restraurent_by_session_token(token)
    end

    test "clears everything previously stored in the session", %{conn: conn, restraurent: restraurent} do
      conn = conn |> put_session(:to_be_removed, "value") |> RestraurentAuth.log_in_restraurent(restraurent)
      refute get_session(conn, :to_be_removed)
    end

    test "redirects to the configured path", %{conn: conn, restraurent: restraurent} do
      conn = conn |> put_session(:restraurent_return_to, "/hello") |> RestraurentAuth.log_in_restraurent(restraurent)
      assert redirected_to(conn) == "/hello"
    end

    test "writes a cookie if remember_me is configured", %{conn: conn, restraurent: restraurent} do
      conn = conn |> fetch_cookies() |> RestraurentAuth.log_in_restraurent(restraurent, %{"remember_me" => "true"})
      assert get_session(conn, :restraurent_token) == conn.cookies[@remember_me_cookie]

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :restraurent_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_restraurent/1" do
    test "erases session and cookies", %{conn: conn, restraurent: restraurent} do
      restraurent_token = Shops.generate_restraurent_session_token(restraurent)

      conn =
        conn
        |> put_session(:restraurent_token, restraurent_token)
        |> put_req_cookie(@remember_me_cookie, restraurent_token)
        |> fetch_cookies()
        |> RestraurentAuth.log_out_restraurent()

      refute get_session(conn, :restraurent_token)
      refute conn.cookies[@remember_me_cookie]
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == ~p"/"
      refute Shops.get_restraurent_by_session_token(restraurent_token)
    end

    test "broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "restraurents_sessions:abcdef-token"
      ZomatoWeb.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> RestraurentAuth.log_out_restraurent()

      assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^live_socket_id}
    end

    test "works even if restraurent is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> RestraurentAuth.log_out_restraurent()
      refute get_session(conn, :restraurent_token)
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "fetch_current_restraurent/2" do
    test "authenticates restraurent from session", %{conn: conn, restraurent: restraurent} do
      restraurent_token = Shops.generate_restraurent_session_token(restraurent)
      conn = conn |> put_session(:restraurent_token, restraurent_token) |> RestraurentAuth.fetch_current_restraurent([])
      assert conn.assigns.current_restraurent.id == restraurent.id
    end

    test "authenticates restraurent from cookies", %{conn: conn, restraurent: restraurent} do
      logged_in_conn =
        conn |> fetch_cookies() |> RestraurentAuth.log_in_restraurent(restraurent, %{"remember_me" => "true"})

      restraurent_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> RestraurentAuth.fetch_current_restraurent([])

      assert conn.assigns.current_restraurent.id == restraurent.id
      assert get_session(conn, :restraurent_token) == restraurent_token

      assert get_session(conn, :live_socket_id) ==
               "restraurents_sessions:#{Base.url_encode64(restraurent_token)}"
    end

    test "does not authenticate if data is missing", %{conn: conn, restraurent: restraurent} do
      _ = Shops.generate_restraurent_session_token(restraurent)
      conn = RestraurentAuth.fetch_current_restraurent(conn, [])
      refute get_session(conn, :restraurent_token)
      refute conn.assigns.current_restraurent
    end
  end

  describe "on_mount :mount_current_restraurent" do
    test "assigns current_restraurent based on a valid restraurent_token", %{conn: conn, restraurent: restraurent} do
      restraurent_token = Shops.generate_restraurent_session_token(restraurent)
      session = conn |> put_session(:restraurent_token, restraurent_token) |> get_session()

      {:cont, updated_socket} =
        RestraurentAuth.on_mount(:mount_current_restraurent, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_restraurent.id == restraurent.id
    end

    test "assigns nil to current_restraurent assign if there isn't a valid restraurent_token", %{conn: conn} do
      restraurent_token = "invalid_token"
      session = conn |> put_session(:restraurent_token, restraurent_token) |> get_session()

      {:cont, updated_socket} =
        RestraurentAuth.on_mount(:mount_current_restraurent, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_restraurent == nil
    end

    test "assigns nil to current_restraurent assign if there isn't a restraurent_token", %{conn: conn} do
      session = conn |> get_session()

      {:cont, updated_socket} =
        RestraurentAuth.on_mount(:mount_current_restraurent, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_restraurent == nil
    end
  end

  describe "on_mount :ensure_authenticated" do
    test "authenticates current_restraurent based on a valid restraurent_token", %{conn: conn, restraurent: restraurent} do
      restraurent_token = Shops.generate_restraurent_session_token(restraurent)
      session = conn |> put_session(:restraurent_token, restraurent_token) |> get_session()

      {:cont, updated_socket} =
        RestraurentAuth.on_mount(:ensure_authenticated, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_restraurent.id == restraurent.id
    end

    test "redirects to login page if there isn't a valid restraurent_token", %{conn: conn} do
      restraurent_token = "invalid_token"
      session = conn |> put_session(:restraurent_token, restraurent_token) |> get_session()

      socket = %LiveView.Socket{
        endpoint: ZomatoWeb.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }

      {:halt, updated_socket} = RestraurentAuth.on_mount(:ensure_authenticated, %{}, session, socket)
      assert updated_socket.assigns.current_restraurent == nil
    end

    test "redirects to login page if there isn't a restraurent_token", %{conn: conn} do
      session = conn |> get_session()

      socket = %LiveView.Socket{
        endpoint: ZomatoWeb.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }

      {:halt, updated_socket} = RestraurentAuth.on_mount(:ensure_authenticated, %{}, session, socket)
      assert updated_socket.assigns.current_restraurent == nil
    end
  end

  describe "on_mount :redirect_if_restraurent_is_authenticated" do
    test "redirects if there is an authenticated  restraurent ", %{conn: conn, restraurent: restraurent} do
      restraurent_token = Shops.generate_restraurent_session_token(restraurent)
      session = conn |> put_session(:restraurent_token, restraurent_token) |> get_session()

      assert {:halt, _updated_socket} =
               RestraurentAuth.on_mount(
                 :redirect_if_restraurent_is_authenticated,
                 %{},
                 session,
                 %LiveView.Socket{}
               )
    end

    test "doesn't redirect if there is no authenticated restraurent", %{conn: conn} do
      session = conn |> get_session()

      assert {:cont, _updated_socket} =
               RestraurentAuth.on_mount(
                 :redirect_if_restraurent_is_authenticated,
                 %{},
                 session,
                 %LiveView.Socket{}
               )
    end
  end

  describe "redirect_if_restraurent_is_authenticated/2" do
    test "redirects if restraurent is authenticated", %{conn: conn, restraurent: restraurent} do
      conn = conn |> assign(:current_restraurent, restraurent) |> RestraurentAuth.redirect_if_restraurent_is_authenticated([])
      assert conn.halted
      assert redirected_to(conn) == ~p"/"
    end

    test "does not redirect if restraurent is not authenticated", %{conn: conn} do
      conn = RestraurentAuth.redirect_if_restraurent_is_authenticated(conn, [])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_authenticated_restraurent/2" do
    test "redirects if restraurent is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> RestraurentAuth.require_authenticated_restraurent([])
      assert conn.halted

      assert redirected_to(conn) == ~p"/restraurents/restraurents/log_in"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "You must log in to access this page."
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> RestraurentAuth.require_authenticated_restraurent([])

      assert halted_conn.halted
      assert get_session(halted_conn, :restraurent_return_to) == "/foo"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> RestraurentAuth.require_authenticated_restraurent([])

      assert halted_conn.halted
      assert get_session(halted_conn, :restraurent_return_to) == "/foo?bar=baz"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> RestraurentAuth.require_authenticated_restraurent([])

      assert halted_conn.halted
      refute get_session(halted_conn, :restraurent_return_to)
    end

    test "does not redirect if restraurent is authenticated", %{conn: conn, restraurent: restraurent} do
      conn = conn |> assign(:current_restraurent, restraurent) |> RestraurentAuth.require_authenticated_restraurent([])
      refute conn.halted
      refute conn.status
    end
  end
end
