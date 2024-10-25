defmodule ZomatoWeb.LiveComponents.CartComponent do
      alias Zomato.Accounts
      alias Zomato.RabbitMQ
      # alias Zomato.Orders
      alias Zomato.Items
      alias Zomato.Carts
    use ZomatoWeb, :live_component



    def update(assigns, socket) do
        cart_items = Carts.list_cart_items(assigns[:cart_id])
        grouped_items = Enum.group_by(cart_items, & &1.item_id)
        {bill, sum} = Enum.reduce(grouped_items, {[], 0}, fn {item_id, items}, {acc_bill, acc_sum} ->
          item = Items.get_item!(item_id)

          # Assuming the quantity is stored in the CartItem schema
          cart_item = List.first(items)
          quantity = cart_item.quantity
          cart_item_id = cart_item.id
          price = Decimal.to_integer(item.price)
          total_amount = price * quantity

          new_bill_item = %{
            cart_item_id: cart_item_id,
            name: item.name,
            quantity: quantity,
            price: price,
            description: item.description,
            total_amount: total_amount,
            photo_url: item.photo_url,
            restaurant_id: item.restaurant_id
          }

          {[new_bill_item | acc_bill], acc_sum + total_amount}
        end)



        {:ok, assign(socket, assigns |> Map.put(:bill, Enum.reverse(bill)) |> Map.put(:total_price, sum))}

    end



    def handle_event("checkout", %{"bill" => json_data}, socket) do
      case Jason.decode(json_data) do
        {:ok, items} when is_list(items) ->

          grouped_items = Enum.group_by(items, fn item -> item["restaurant_id"] end)
          line_items =
            Enum.map(items, fn item ->
              %{
                price_data: %{
                  currency: "usd",
                  product_data: %{
                    name: item["name"],
                    description: item["description"],
                    images: ["https://restaurantindia.s3.ap-south-1.amazonaws.com/s3fs-public/2024-02/zomato-infinity-dining-916x516-1_11zon%20%282%29_0.jpg"]
                  },
                  unit_amount: item["price"]
                },
                quantity: item["quantity"]
              }
            end)

            IO.inspect(line_items, label: "Line Items")

          {:ok, checkout_session} =
            Stripe.Checkout.Session.create(%{
              line_items: line_items,
              mode: :payment,
              success_url: url(~p"/warehouse/users/success/#{socket.assigns.cart_id}"),
              cancel_url: url(~p"/"),
              metadata: %{"cart_id" => socket.assigns.cart_id}
            })

            user = Accounts.get_user!(socket.assigns.id)

            payload = %{
              cart_id: socket.assigns.cart_id,
              user_id: socket.assigns.id,
              name: user.name,
              checkout_session_id: checkout_session.id,
              email: user.email,
              group_items: grouped_items
            }

            payload = Jason.encode!(payload)

            RabbitMQ.publish(payload)

            # Enum.each(grouped_items, fn {restaurant_id, items_for_restaurant} ->
            #   total_amount_for_restaurant =
            #     Enum.reduce(items_for_restaurant, 0, fn item, acc ->
            #       acc + (item["price"] * item["quantity"])
            #     end)
            #     Orders.create_order(socket.assigns.cart_id, socket.assigns.id, restaurant_id, total_amount_for_restaurant)
            # end)

          {:noreply, redirect(socket, external: checkout_session.url)}

        {:error, _reason} ->
          {:noreply, put_flash(socket, :error, "Failed to decode JSON")}

        _ ->
          {:noreply, put_flash(socket, :error, "Unexpected data structure")}
      end
    end


    def handle_event("delete_cart_item", %{"id" => id}, socket) do
      case Zomato.Cart.delete_cart_item_id(id) do
          {:ok, _deleted_item} ->
              cart_items = Carts.list_cart_items(socket.assigns.cart_id)
              grouped_items = Enum.group_by(cart_items, & &1.item_id)
              {bill, sum} = Enum.reduce(grouped_items, {[], 0}, fn {item_id, items}, {acc_bill, acc_sum} ->
                  item = Items.get_item!(item_id)
                  quantity = length(items)
                  cart_item_id = List.first(items).id
                  price = Decimal.to_integer(item.price) # Convert Decimal to integer
                  total_amount = price * quantity
                  new_bill_item = %{
                  cart_item_id: cart_item_id, ## want cart_item_id
                  name: item.name,
                  quantity: quantity,
                  price: price,
                  total_amount: total_amount,
                  photo_url: item.photo_url
                  }

                  {[new_bill_item | acc_bill], acc_sum + total_amount}
              end)

              {:noreply,
               socket
               |> assign(bill: bill, total_price: sum)}

        {:error, :not_found} ->
          {:noreply, put_flash(socket, :error, "Cart item not found")}
      end
    end





  def render(assigns) do
    ~H"""
    <div id="cart_page">
        <h1 class="text-2xl font-bold text-black mb-6">Shopping Cart</h1>

        <div class="overflow-y-auto max-h-96 space-y-4">
        <%= for item <- @bill do %>
        <div class="flex items-center justify-between p-4 border-b">
            <div class="flex items-center">
                <img src={item.photo_url} alt="Item Image" class="w-20 h-20 object-cover rounded-md mr-4" />
                <div>
                    <h2 class="text-lg font-semibold"><%= item.name %></h2>
                    <p class="text-gray-500">Quantity: <%= item.quantity %></p>
                    <span class="text-gray-700 font-bold">$<%=item.price %></span>
                </div>
            </div>
            <div class="flex items-center">
                <button class="bg-gray-300 text-gray-700 px-2 py-1 rounded-md hover:bg-gray-400">-</button>
                <span class="mx-2">1</span>
                <button class="bg-gray-300 text-gray-700 px-2 py-1 rounded-md hover:bg-gray-400">+</button>
                <button phx-click="delete_cart_item" phx-target={@myself} phx-value-id={item.cart_item_id} class="bg-red-500 text-center text-white px-2 py-1 ml-4 rounded-full hover:bg-red-600 font-bold w-10 h-10">X</button>
            </div>
        </div>
        <% end %>

        <div class="flex justify-between mt-6 border-t pt-4">
            <span class="text-lg font-bold">Total:</span>
            <span class="text-lg font-bold">$<%= @total_price %></span>
        </div>

        <div class="mt-6">
            <button phx-click="checkout" phx-target={@myself} phx-value-bill={Jason.encode!(@bill)}  class="w-full bg-green-500 text-white py-2 rounded-md hover:bg-green-600 transition duration-200">Proceed to Checkout</button>
        </div>
    </div>
    </div>


    """
  end

end
