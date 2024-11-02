defmodule ZomatoWeb.Warehouse.RestraurentAboutLive do
    alias Zomato.Shops
    alias Zomato.Accounts
    alias Zomato.Items
    alias Zomato.Carts
    alias ZomatoWeb.FooterComponent
    alias ZomatoWeb.LiveComponents.OverviewLive
    alias ZomatoWeb.LiveComponents.ReviewLive
    alias ZomatoWeb.LiveComponents.PhotosLive
    alias ZomatoWeb.LiveComponents.MenuLive
    alias ZomatoWeb.LiveComponents.NavbarLive
    use ZomatoWeb, :live_view

    @impl true
    def mount(%{"id" => id}= _params, session, socket) do
        if connected?(socket), do: Carts.subscribe_to_product_events()

        user = Accounts.get_user_by_session_token(session["user_token"])
        restraurant = Shops.get_restraurent!(id)

        if(restraurant == nil) do
            socket =
                socket
                |> Phoenix.LiveView.redirect(to: ~p"/error")

            {:ok, socket}

        else
            socket =
                socket
                |> assign(:cart_id, session["cart_id"])
                |> assign(:id, id)
                |> assign(:restaurant, restraurant)
                |> assign(:user, user)
                |> assign(:active_section, "overview")
                |> stream(:items, Items.list_items_by_restaurant(id))
                |> assign(:uploaded_files,[])
                |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png), max_entries: 1)


            {:ok, socket}
        end



    end

    def handle_info({:flash_info, message}, socket) do
      {:noreply, socket |> put_flash(:info, message)}
    end

    @impl true
    def handle_info(:clear_flash, socket) do
        {:noreply, clear_flash(socket)}
    end


    @impl true
    def handle_info({:item_updated, updated_product}, socket) do
        {:noreply, stream_insert(socket, :items, updated_product)}
    end

    @impl true
    def handle_info({:item_created, created_product}, socket) do
        {:noreply, stream_insert(socket, :items, created_product)}
    end

    @impl true
    def handle_event("show_section", %{"section" => section}, socket) do
        {:noreply, assign(socket, active_section: section)}
    end





    @impl true
    def render(assigns) do
    ~H"""
    <div class="max-w-screen-lg mx-auto p-4">
    <!-- Header with Logo, Search, and Profile Icon -->
    <.live_component module={NavbarLive} id={@user.id} cart_id={@cart_id}/>

    <!-- Restaurant Information Section -->
    <div class="flex flex-col sm:flex-row items-center gap-4">
        <div class="w-full sm:w-1/3 h-72 bg-cover bg-center rounded-lg" style={"background-image: url(#{@restaurant.profile_pic});"}></div>
        <div class="w-full sm:w-2/3 flex flex-col gap-2">
        <div class="text-2xl font-semibold"><%=@restaurant.name%></div>
            <div class="text-lg text-gray-700">Rating: 4.5</div>
            <div class="text-gray-600">Address: <%=@restaurant.address%></div>
            <div class="text-gray-600">Phone: <%=@restaurant.phone%></div>
            <div class="text-gray-600">Email: <%=@restaurant.email%></div>
            <div class="text-gray-600">Open now: 11am – 9:30pm (Today)</div>
        </div>
    </div>

    <!-- Tab Navigation -->
    <nav class="flex justify-around bg-white shadow-md rounded-lg mt-8">
        <button phx-click="show_section" phx-value-section="overview" class="text-gray-700 hover:text-red-600 py-4 px-6 font-semibold">Overview</button>
        <button phx-click="show_section" phx-value-section="reviews" class="text-gray-700 hover:text-red-600 py-4 px-6 font-semibold">Reviews</button>
        <button phx-click="show_section" phx-value-section="photos" class="text-gray-700 hover:text-red-600 py-4 px-6 font-semibold">Photos</button>
        <button phx-click="show_section" phx-value-section="menu" class="text-gray-700 hover:text-red-600 py-4 px-6 font-semibold">Menu</button>
    </nav>

    <!-- Section Content -->
    <div class="mt-8">
        <%= if @active_section == "overview" do %>
            <h2 class="text-2xl font-bold mb-4">Restraurent Overview</h2>
            <p class="text-gray-700">
            A quick glance at your restaurant's performance and recent activities.</p>
            <.live_component module={OverviewLive} id={0} />
        <% end %>

        <%= if @active_section == "reviews" do %>
            <h2 class="text-2xl font-bold mb-4">Customers Reviews</h2>
            <.live_component module={ReviewLive} id={0} user={0} user_id={@user.id} restraurant_id={@id}/>
        <% end %>

        <%= if @active_section == "photos" do %>
            <.live_component module={PhotosLive} id={@id} user={1} userdetails={@user}/>
        <% end %>

        <%= if @active_section == "menu" do %>
            <%!-- <h2 class="text-2xl font-bold mb-4">Menu</h2>
            <p class="text-gray-700">This is the menu section. Explore the variety of dishes offered at this restaurant.</p> --%>
            <.live_component module={MenuLive} id={@id} cart_id={@cart_id} user={1} userdetails={@user}/>
        <% end %>
    </div>
    </div>
    <.live_component module={FooterComponent} id={0}/>

    """


  end
end
