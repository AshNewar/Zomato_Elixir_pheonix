defmodule ZomatoWeb.Warehouse.UserDashLive do
  alias ZomatoWeb.LiveComponents.FollowLive
  alias Zomato.Reviews
  alias Zomato.Orders
  alias ZomatoWeb.LiveComponents.OrderLive
  alias Zomato.Accounts
  alias Zomato.Accounts.User
  alias ZomatoWeb.LiveComponents.{ReviewLive, NavbarLive, PhotosLive}
  alias ZomatoWeb.FooterComponent
  use ZomatoWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])

    form =
      %User{}
      |> User.update_changeset(%{})
      |> to_form(as: "form_data")

    ordersdetails = Orders.get_orders_summary_for_user(user.id)
    review_detail = Reviews.get_review_summary_user(user.id)


    {:ok,
      socket
      |> assign(current_section: "myReviews")
      |> assign(orders: ordersdetails)
      |> assign(reviews: review_detail)
      |> assign(search_results: nil)
      |> assign(user: user)
      |> assign(:form_data, form)
      |> assign(:uploaded_files,[])
      |> assign(:cart_id, session["cart_id"])
      |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png), max_entries: 1)

    }
  end


  def handle_event("change_section", %{"section" => section}, socket) do
    {:noreply, assign(socket, current_section: section)}
  end


  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("save_profile", %{"form_data" => form_data}, socket) do
    user = socket.assigns.current_user
    form_data =
      if uploaded_files = List.first(upload_files(socket)) do
        form_data
        |> Map.put("profile_pic", uploaded_files)
      else
        form_data
        |> Map.put("profile_pic" , user.profile_pic)
      end

    case Accounts.update_user(user.id, form_data) do
      {:ok, _updated_user} ->

        socket=
          socket
          |> put_flash(:info, "Profile updated successfully.")
          |> push_navigate(to: ~p"/warehouse/users/dashboard")


          {:noreply, socket}

        {:error, changeset} ->
          # Handle the case where the update fails
          {:noreply, assign(socket, :error, changeset)}
    end
  end

  defp upload_files(socket) do
    consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
      dest = Path.join([:code.priv_dir(:zomato), "static", "uploads", Path.basename(path)])
      IO.inspect(dest, label: "dest")
      IO.inspect(path, label: "path")

      File.cp!(path, dest)

      {:postpone, ~p"/uploads/#{Path.basename(dest)}"}
    end)

  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"



  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-screen-lg mx-auto p-4">
      <.live_component module={NavbarLive} id={@cart_id} cart_id={@cart_id} />

      <div class="bg-zomato rounded-lg shadow-md p-6 mb-6 flex justify-between items-center text-white">
        <div class="flex items-center">
          <div class="w-24 h-24 rounded-full bg-gray-200 bg-cover mr-6 border-white border-2" style={"background-image: url(#{@user.profile_pic});"}></div>
          <div>
            <h1 class="text-3xl font-bold"><%= @user.name%></h1>
            <p>Email: <%= @user.email%></p>
            <p>Phone: <%= @user.phone%></p>
            <p>Location: <%= @user.address%></p>
          </div>
        </div>
        <button phx-click={show_modal("edit_profile_user")} class="bg-red-400 text-white py-2 px-4 rounded-lg transition duration-200 ease-in-out hover:bg-red-500">Edit Profile</button>

      </div>

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


      <!-- Main Content -->
      <div class="bg-white rounded-lg shadow-md p-6 flex flex-col">
        <nav class="flex justify-around bg-white shadow-md rounded-lg">
          <button phx-click="change_section" phx-value-section="myReviews" class="text-gray-700 hover:text-red-600 py-4 px-6 font-semibold">Review</button>
          <button phx-click="change_section" phx-value-section="myPhotos" class="text-gray-700 hover:text-red-600 py-4 px-6 font-semibold">Photos</button>
          <button phx-click="change_section" phx-value-section="myFollowers" class="text-gray-700 hover:text-red-600 py-4 px-6 font-semibold">Followers</button>
          <button phx-click="change_section" phx-value-section="address" class="text-gray-700 hover:text-red-600 py-4 px-6 font-semibold">Orders</button>
        </nav>

        <div class="w-full mt-5">
          <!-- Conditional Rendering for Sections -->
          <%= if @current_section == "myReviews" do %>
            <.live_component module={ReviewLive} id={1} user={1} user_id={@user.id}/>
          <% end %>

          <%= if @current_section == "myPhotos" do %>
            <.live_component module={PhotosLive} id={@user.id} user={0} userdetails={@user}/>
          <% end %>

          <%= if @current_section == "myFollowers" do %>
            <.live_component module={FollowLive} id={@user.id} show={0}/>
          <% end %>

          <%= if @current_section == "address" do %>
            <.live_component module={OrderLive} id={@user.id}/>

          <% end %>

        </div>
      </div>
    </div>
    <.live_component module={FooterComponent} id={0}/>
    <.modal id="edit_profile_user">
    <div class="">
        <h2 class="text-center font-bold"> Edit Details</h2>
        <.simple_form  for={@form_data} phx-submit="save_profile" phx-change="validate" class="flex-col gap-2 items-center mb-4">
        <div class="mb-4">
            <.input type="text" label="Name" field={@form_data[:name]} class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="example@shop.com"/>
        </div>

        <div class="mb-4">
            <.input type="text" label="Address" field={@form_data[:address]} class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="example@shop.com"/>
        </div>
        <div class="mb-4">
            <.input type="number" label="Phone" field={@form_data[:phone]} class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="example@shop.com"/>
        </div>
        <div class="flex">
          <.live_file_input upload={@uploads.avatar} class="block p-2 border border-gray-300 rounded-lg w-full" />
        </div>

        <section phx-drop-target={@uploads.avatar.ref} class="flex flex-col gap-4">
          <%= for entry <- @uploads.avatar.entries do %>
            <article class="upload-entry flex items-center gap-4 p-4 bg-white shadow rounded-lg">
              <figure class="w-24 h-24 rounded-full overflow-hidden flex-shrink-0">
                <.live_img_preview entry={entry} class="w-full h-full object-cover" />
              </figure>
              <div class="flex-1">
                <figcaption class="font-medium text-center mb-2"><%= entry.client_name %></figcaption>
                <progress value={entry.progress} max="100" class="w-full h-2 bg-gray-200 rounded-lg overflow-hidden">
                  <%= entry.progress %>%
                </progress>
              </div>
              <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref} aria-label="cancel" class="text-red-600 text-2xl hover:text-red-800">&times;</button>
            </article>
          <% end %>

          <%= for err <- upload_errors(@uploads.avatar) do %>
            <p class="alert alert-danger text-red-600 font-medium"><%= error_to_string(err) %></p>
          <% end %>
        </section>
        <button type="submit" phx-disable-with="Saving Changes ..." class="mt-2 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 w-full">Save Changes</button>
        </.simple_form>

      </div>

      </.modal>
    """
  end
end
