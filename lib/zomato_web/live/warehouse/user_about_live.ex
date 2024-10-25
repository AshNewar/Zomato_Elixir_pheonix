defmodule ZomatoWeb.Warehouse.UserAboutLive do
  alias ZomatoWeb.LiveComponents.FollowLive
  alias Zomato.Reviews
  alias Zomato.Orders
  alias ZomatoWeb.LiveComponents.OrderLive
  alias Zomato.Accounts
  alias ZomatoWeb.LiveComponents.{ReviewLive, NavbarLive, PhotosLive}
  alias ZomatoWeb.FooterComponent
  use ZomatoWeb, :live_view

  @impl true
  def mount(%{"user_id" => user_id}, session, socket) do
    user = Accounts.get_user!(user_id)
    ordersdetails = Orders.get_orders_summary_for_user(user.id)
    review_detail = Reviews.get_review_summary_user(user.id)

    {:ok,
      socket
      |> assign(current_section: "myReviews")
      |> assign(cur_section: "following")
      |> assign(search_results: nil)
      |> assign(orders: ordersdetails)
      |> assign(reviews: review_detail)
      |> assign(user: user)
      |> assign(cart_id: session["cart_id"])
      |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png), max_entries: 1)

    }
  end

  @impl true
  def handle_event("change_section", %{"section" => section}, socket) do
    {:noreply, assign(socket, current_section: section)}
  end

  def handle_event("change_sec", %{"section" => section}, socket) do
    {:noreply, assign(socket, cur_section: section)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-screen-lg mx-auto p-4">
      <.live_component module={NavbarLive} id={@cart_id} cart_id={@cart_id} />

      <!-- Profile Header -->
      <div class="bg-zomato rounded-lg shadow-md p-6 mb-6 flex justify-between items-center text-white">
        <div class="flex items-center">
          <div class="w-24 h-24 rounded-full bg-gray-200 bg-cover mr-6 border-white border-2" style={"background-image: url(#{@user.profile_pic});"}></div>
          <div>
            <h1 class="text-3xl font-bold"><%=@user.name%></h1>
            <p>Email: <%= @user.email%></p>
            <p>Phone: <%= @user.phone%></p>
            <p>Location: <%= @user.address%></p>
          </div>
        </div>

      </div>

      <!-- Followers and Reviews Counter -->
      <div class="flex flex-wrap justify-center mb-6"> <!-- Changed to justify-center -->
        <div class="bg-white shadow-md rounded-lg p-4 flex-1 max-w-xs m-2"> <!-- Added max-w-xs for consistent width -->
          <h3 class="text-xl font-bold mb-2">Reviews</h3>
          <p class="text-3xl text-blue-600"><%=@reviews.total_reviews%></p>
        </div>
        <div class="bg-white shadow-md rounded-lg p-4 flex-1 max-w-xs m-2"> <!-- Example additional card -->
          <h3 class="text-xl font-bold mb-2">Followers</h3>
          <p class="text-3xl text-blue-600">10</p>
        </div>
        <div class="bg-white shadow-md rounded-lg p-4 flex-1 max-w-xs m-2"> <!-- Example additional card -->
          <h3 class="text-xl font-bold mb-2">Orders</h3>
          <p class="text-3xl text-blue-600"><%=@orders.total_orders%></p>
        </div>
        <div class="bg-white shadow-md rounded-lg p-4 flex-1 max-w-xs m-2"> <!-- Example additional card -->
          <h3 class="text-xl font-bold mb-2">ZomatoPoints</h3>
          <p class="text-3xl text-blue-600">
            <%= if @orders.total_amount do %>
              <%= @orders.total_amount %>
            <% else %>
              0
            <% end %>
          </p>
        </div>
      </div>


      <div class="bg-white rounded-lg shadow-md p-6 flex flex-col">
        <nav class="flex justify-around bg-white shadow-md rounded-lg">
          <button phx-click="change_section" phx-value-section="myReviews" class="text-gray-700 hover:text-red-600 py-4 px-6 font-semibold">Review</button>
          <button phx-click="change_section" phx-value-section="myPhotos" class="text-gray-700 hover:text-red-600 py-4 px-6 font-semibold">Photos</button>
          <button phx-click="change_section" phx-value-section="myFollowers" class="text-gray-700 hover:text-red-600 py-4 px-6 font-semibold">Followers</button>
          <button phx-click="change_section" phx-value-section="address" class="text-gray-700 hover:text-red-600 py-4 px-6 font-semibold">Orders</button>
          <%!-- <button phx-click="change_section" phx-value-section="zomatoPoints" class="text-gray-700 hover:text-red-600 py-4 px-6 font-semibold">ZomatoPoints</button> --%>
        </nav>

        <div class="w-full mt-5">
          <%= if @current_section == "myReviews" do %>
            <.live_component module={ReviewLive} id={1} user={1} user_id={@user.id}/>
          <% end %>

          <%= if @current_section == "myPhotos" do %>
            <.live_component module={PhotosLive} id={@user.id} user={0}/>
          <% end %>

          <%= if @current_section == "myFollowers" do %>
            <.live_component module={FollowLive} id={@user.id} show={1}/>
          <% end %>

          <%= if @current_section == "address" do %>
           <.live_component module={OrderLive} id={@user.id}/>
          <% end %>
        </div>
      </div>
    </div>
    <.live_component module={FooterComponent} id={0}/>
    """
  end
end
