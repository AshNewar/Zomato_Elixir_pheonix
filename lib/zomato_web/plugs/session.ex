defmodule ZomatoWeb.Plugs.SessionCart do
  @behaviour Plug

  import Plug.Conn

  alias Zomato.Carts

  @impl true
  def init(default), do: default

  @impl true
  def call(conn, _config) do
    case get_session(conn, :cart_id) do
      nil ->
        {:ok, %{id: cart_id}} = Carts.create_cart()
        put_session(conn, :cart_id, cart_id)

      cart_id ->
        case Carts.get_cart(cart_id) do
          %{status: :open} ->
            conn

          _cart ->
            {:ok, %{id: cart_id}} = Carts.create_cart()
            put_session(conn, :cart_id, cart_id)
        end
    end
  end


end
