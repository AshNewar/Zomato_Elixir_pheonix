defmodule ZomatoWeb.LiveComponents.OrderLive do
      alias Zomato.Orders
  use ZomatoWeb, :live_component


  def update(assigns, socket) do
    orders = Orders.get_orders_for_user(assigns.id)
    socket = socket |> assign(:orders, orders)
    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-6">
    <h1 class="text-3xl font-bold text-center mb-6">Your Orders</h1>

    <div class="overflow-x-auto">
      <table class="min-w-full bg-white shadow-md rounded-lg">
        <thead class="bg-gray-100">
          <tr class="text-left">
            <th class="py-2 px-4 border-b">Order ID</th>
            <th class="py-2 px-4 border-b">Restaurant Name</th>
            <th class="py-2 px-4 border-b">Total Price</th>
            <th class="py-2 px-4 border-b">Status</th>
          </tr>
        </thead>
        <tbody>
          <%= for order <- @orders do %>
            <tr class="hover:bg-gray-50">
              <td class="py-2 px-4 border-b"><%= order.id %></td>
              <td class="py-2 px-4 border-b"><%= order.restaurant.name %></td>
              <td class="py-2 px-4 border-b">$ <%= order.total_amount%></td>
              <td class="py-2 px-4 border-b"><%= order.status %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
      </div>
    </div>

    """
  end
end
