defmodule ZomatoWeb.Warehouse.SuccessLive do
  @moduledoc """
  Success live view.
  """

      alias ZomatoWeb.FooterComponent
      alias Zomato.Carts
  use ZomatoWeb, :live_view


  @impl true
  def mount(_params, session, socket) do
    cart = Carts.get_cart(session["cart_id"])

    {:ok, assign(socket, :cart, cart)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-1 px-6 mt-5 max-w-screen-lg  mx-auto" id="cart_items" phx-update="stream">
      <div class="max-w-screen-lg mx-auto flex flex-col justify-center items-center px-4 py-4 gap-4 text-center">

        <h1 class="text-3xl pb-6 font-semibold">You did it!</h1>
        <h1 class="text-4xl pb-6 font-semibold text-lime-400">Payment Successful Your Order is On the Way</h1>

        <p>Thanks for your Order!</p>
        <p> You will soon Receive a Order Confirmation Mail from Us</p>
        <.link href={~p"/"} class="bg-blue-600 text-white font-semibold py-2 px-4 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50">
          Order More
        </.link>

      </div>

    </div>
    <.live_component module={FooterComponent} id={0}/>
    """
  end
end
