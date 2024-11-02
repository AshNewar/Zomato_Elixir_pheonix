defmodule ZomatoWeb.Restraurents.RestraurentSessionController do
  use ZomatoWeb, :controller

  alias Zomato.Shops
  alias ZomatoWeb.Restraurents.RestraurentAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:restraurent_return_to, ~p"/restraurents/restraurents/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"restraurent" => restraurent_params}, info) do
    %{"email" => email, "password" => password} = restraurent_params

    if restraurent = Shops.get_restraurent_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> RestraurentAuth.log_in_restraurent(restraurent, restraurent_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Invalid email or password")
      # |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> RestraurentAuth.log_out_restraurent()
  end
end
