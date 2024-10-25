defmodule ZomatoWeb.LiveComponents.MenuLive do
      alias Zomato.Carts
    use ZomatoWeb, :live_component

    alias Zomato.Items

    @impl true
    def update(%{id: restraurent_id , user: user, cart_id: cart_id ,userdetails: users} = assigns, socket) do
      items = Items.list_items_by_restaurant(restraurent_id)
      {:ok, assign(socket, assigns |> Map.put(:items, items) |> Map.put(:user, user) |> Map.put(:cart_id, cart_id) |> Map.put(:users, users))}
    end

    @impl true
    def handle_event("add_to_cart", %{"id" => id}, socket) do
      item = Items.get_item!(id)
      Carts.add_item_to_cart(socket.assigns.cart_id, item.id, socket.assigns.users.id,item.restaurant_id)
      Process.send_after(self(), :clear_flash, 2500)
      send(self(), {:flash_info, "Added to cart"})
      {:noreply, socket}
  end

    def handle_info(:clear_flash, socket) do
      {:noreply, clear_flash(socket)}
  end



    @impl true
    def render(assigns) do
      ~H"""
      <div id="menu" class="section mt-8">
        <h2 class="text-2xl font-bold mb-4">Menu</h2>
        <p class="text-gray-700">This is the menu section. Explore the variety of dishes offered at this restaurant.</p>
        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6 mt-5">
          <%= for item <- @items do %>
            <div class="bg-white border border-gray-200 rounded-lg shadow-md p-4 transition-transform transform hover:scale-105">
              <img src={item.photo_url} alt="Item Image" class="w-full h-32 object-cover rounded-t-lg">
              <h3 class="text-lg font-bold mt-2"><%= item.name %></h3>
              <p class="text-gray-600">Price: <%= item.price %></p>
              <%= if @user != 0 do %>
              <button phx-click="add_to_cart" phx-target={@myself} phx-value-id={item.id} class=" w-full mt-4 bg-red-600 text-white py-2 rounded hover:bg-red-700 focus:outline-none">
                Add
              </button>
                <% end %>
            </div>
          <% end %>
        </div>
      </div>
      """
    end
  end
