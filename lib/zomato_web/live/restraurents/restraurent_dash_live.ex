defmodule ZomatoWeb.Restraurents.RestraurentDashLive do
      alias Zomato.Cart
      alias Zomato.Orders
  use ZomatoWeb, :live_view
  alias ZomatoWeb.NavbarComponent


  def mount(_params, _session, socket) do
    pending_orders = Orders.get_orders_by_restaurant_id_pending(socket.assigns.current_restraurent.id)
    completed_orders = Orders.get_orders_by_restaurant_id_completed(socket.assigns.current_restraurent.id)

    socket =
      socket |> assign(:pending_orders, pending_orders) |> assign(:completed_orders, completed_orders)
      |> assign(:selected_order ,nil) |> assign(:points, [length(pending_orders),length(completed_orders)])

    {:ok, socket}

  end


  def handle_event("select_order", %{"user_address" => user_address, "user_name" => user_name, "user_phone" => user_phone, "user_email" => user_email, "cart_id" => cart_id , "restaurent_id" => restaurent_id}, socket) do
    items_list = Cart.get_cart_item_by_cart_rest_id(cart_id, restaurent_id)
    details_order = %{
      name: user_name,
      phone: user_phone,
      email: user_email,
      address: user_address,
      items_list: items_list
    }


    socket = assign(socket, :selected_order, details_order)

    {:noreply, socket}
  end

  def handle_event("order_update", %{"id" => id}, socket) do

    Orders.update_order_status_to_completed(id)
    pending_orders = Orders.get_orders_by_restaurant_id_pending(socket.assigns.current_restraurent.id)
    completed_orders = Orders.get_orders_by_restaurant_id_completed(socket.assigns.current_restraurent.id)

    socket = assign(socket, :pending_orders, pending_orders)
    socket = assign(socket , :completed_orders, completed_orders)

    {:noreply, socket}


  end



  def render(assigns) do
    ~H"""
    <div class="bg-gray-100 h-screen flex flex-col">

      <!-- Navbar Component -->
      <.live_component module={NavbarComponent} id={0} />

      <!-- Main Content Area -->
      <div class="flex-1 p-6 overflow-auto">
        <h2 class="text-3xl font-semibold mb-6">Your Orders</h2>

        <!-- Order Statistics Cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-6">
          <div class="bg-white shadow-md rounded-lg p-4">
            <h3 class="text-xl font-bold mb-2">Pending Orders</h3>
            <p class="text-3xl text-blue-600"><%= length(@pending_orders)%></p>
          </div>
          <div class="bg-white shadow-md rounded-lg p-4">
            <h3 class="text-xl font-bold mb-2">Delivered Orders</h3>
            <p class="text-3xl text-green-600"><%= length(@completed_orders)%></p>
          </div>
          <div class="bg-white shadow-md rounded-lg p-4">
            <h3 class="text-xl font-bold mb-2">Total Orders</h3>
            <p class="text-3xl text-purple-600"><%= length(@pending_orders) + length(@completed_orders)%></p>
          </div>
          <div class="bg-white shadow-md rounded-lg p-4">
            <h3 class="text-xl font-bold mb-2">Total Earnings</h3>
            <p class="text-3xl text-red-600">$1500</p>
          </div>
        </div>

        <!-- Orders Table -->
        <div class=" mx-auto p-4">
      <div class="flex flex-col  md:flex-row md:space-x-8 space-y-8 md:space-y-0">

        <!-- Pending Orders Section -->
        <div class="md:w-1/3 w-full overflow-x-auto">
          <h2 class="text-xl font-semibold mb-4 text-gray-800">Pending Orders</h2>
          <table class="min-w-full bg-white border border-gray-300">
            <thead>
              <tr class="bg-gray-200">
                <th class="py-2 px-4 border-b text-center">Order ID</th>
                <th class="py-2 px-4 border-b text-center">Customer Name</th>
                <th class="py-2 px-4 border-b text-center">Total</th>
                <th class="py-2 px-4 border-b text-center">Order Details</th>
                <th class="py-2 px-4 border-b text-center">Done</th>
              </tr>
            </thead>
            <tbody>
            <%= for o <- @pending_orders do%>
              <tr class="text-center">
                <td class="py-2 px-4 border-b"><%= o.id %></td>
                <td class="py-2 px-4 border-b"><%= o.user.name %></td>
                <td class="py-2 px-4 border-b">$<%= o.total_amount %></td>
                <td class="py-2 px-4 border-b">
                <button
                  phx-click={JS.push("select_order") |> show_modal("order_page")}
                  phx-value-user_name={o.user.name}
                  phx-value-user_phone={o.user.phone}
                  phx-value-user_email={o.user.email}
                  phx-value-user_address={o.user.address}
                  phx-value-cart_id={o.cart_id}
                  phx-value-restaurent_id={o.restaurant_id}
                  class="bg-blue-500 text-white font-semibold py-2 px-4 rounded-lg hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-opacity-75">

                    View Details
                  </button>
                </td>
                <td class="py-2 px-4 border-b">
                  <button phx-click="order_update" phx-value-id={o.id} class="bg-lime-500 text-white font-semibold py-2 px-4 rounded-lg hover:bg-lime-600 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-opacity-75">
                    Done
                  </button>
                </td>
              </tr>

            <% end%>



              <!-- Additional pending orders here -->
            </tbody>
          </table>

        </div>

        <!-- Delivered Orders Section -->
        <div class="md:w-1/3 w-full overflow-x-auto">
          <h2 class="text-xl font-semibold mb-4 text-gray-800">Delivered Orders</h2>
          <table class="min-w-full bg-white border border-gray-300">
            <thead>
              <tr class="bg-gray-200">
                <th class="py-2 px-4 border-b text-center">Order ID</th>
                <th class="py-2 px-4 border-b text-center">Customer Name</th>
                <th class="py-2 px-4 border-b text-center">Total</th>
                <th class="py-2 px-4 border-b text-center">Status</th>
              </tr>
            </thead>
            <tbody>
            <%= for o <- @completed_orders do%>
              <tr class="text-center">
                <td class="py-2 px-4 border-b"><%= o.id %></td>
                <td class="py-2 px-4 border-b"><%= o.user.name %></td>
                <td class="py-2 px-4 border-b">$<%= o.total_amount %></td>
                <td class="py-2 px-4 border-b">
                <button
                  phx-click={JS.push("select_order") |> show_modal("order_page")}
                  phx-value-user_name={o.user.name}
                  phx-value-user_phone={o.user.phone}
                  phx-value-user_email={o.user.email}
                  phx-value-user_address={o.user.address}
                  phx-value-cart_id={o.cart_id}
                  phx-value-restaurent_id={o.restaurant_id}
                  class="bg-blue-500 text-white font-semibold py-2 px-4 rounded-lg hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-opacity-75">

                    View Details
                  </button>
                </td>
              </tr>

              <%end%>
            </tbody>
          </table>
        </div>

    <!-- Graph Section -->
        <div class="md:w-1/3 w-full ">
          <h2 class="text-xl font-semibold mb-4 text-gray-800">Order Status Graph</h2>
          <div class="bg-white shadow rounded-lg p-6 flex justify-center items-center">
            <canvas id="orderChart" class="w-full h-64" phx-hook="ChartJS" data-points={Jason.encode!(@points)}></canvas>
          </div>
        </div>

      </div>
    </div>
          </div>
    </div>

    <%= if @selected_order do %>

    <.modal id="order_page">

    <h1 class="text-4xl font-bold text-center text-red-600 mb-6">User Details</h1>

      <p class="text-xl font-semibold text-blue-600 mb-2">Name:
        <span class="font-normal text-blue-900"><%= @selected_order.name %></span>
      </p>

      <p class="text-xl font-semibold text-blue-600 mb-2">Phone:
        <span class="font-normal text-blue-900"><%= @selected_order.phone %></span>
      </p>

      <p class="text-xl font-semibold text-blue-600 mb-6">Address:
        <span class="font-normal text-blue-900"><%= @selected_order.address %></span>
      </p>

      <h1 class="text-4xl font-bold text-center text-lime-600 mb-6">Order Details</h1>

      <div class="bg-gray-50 shadow-md rounded-lg p-4">
        <%= for item <- @selected_order.items_list do %>
        <div class="flex justify-between items-center border-b border-gray-300 py-2 hover:bg-yellow-100 transition duration-200 ease-in-out">
          <p class="text-lg font-bold text-purple-700"><%= item.item.name %></p>
          <p class="text-lg font-semibold text-green-600">$<%= item.item.price %></p>
        </div>
        <% end %>
      </div>



    </.modal>
    <% end %>

    <%!-- <.modal id="order_done">
        <h1 class="text-red-600 font-bold text-2xl">Is The Order Delivered ?</h1>
        <div class="flex px-6 py-6 justify-center items-center space-x-4 max-w-screen-sm mx-auto">
          <.link phx-click="order_update" phx-value-id={@id} method="delete" class="bg-lime-600 text-white font-semibold py-2 px-4 rounded-lg hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-opacity-50">
            Yes
          </.link>
          <.link phx-click={hide_modal("order_done")} class="bg-red-600 text-white font-semibold py-2 px-4 rounded-lg hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-opacity-50">
            No
          </.link>
        </div>

    </.modal> --%>
    """
  end
end
