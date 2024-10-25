defmodule ZomatoWeb.Restraurents.RestraurentProfileLive do
  alias Zomato.Shops.Restraurent
  alias Zomato.Shops
  alias ZomatoWeb.NavbarComponent
  alias ZomatoWeb.FooterComponent
  alias ZomatoWeb.LiveComponents.OverviewLive
  alias ZomatoWeb.LiveComponents.ReviewLive
  alias ZomatoWeb.LiveComponents.PhotosLive
  alias ZomatoWeb.LiveComponents.MenuLive
  use ZomatoWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, %{"restraurent_token" => restraurent_token,"cart_id" => cart_id}=_session, socket) do
  restaurant = Shops.get_restraurent_by_session_token(restraurent_token)  # Assuming you have a way to get the restaurant ID from the session
  form =
    %Restraurent{}
    |> Restraurent.update_changeset(%{})
    |> to_form(as: "form_data")
  socket =
    socket
    |> assign(active_section: "overview" , restaurant: restaurant )
    |> assign(:uploaded_files,[])
    |> assign(:form_data, form)
    |> assign(:cart_id, cart_id)
    |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png), max_entries: 1)


  {:ok, socket}
  end

  @impl true
  def handle_event("show_section", %{"section" => section}, socket) do
  {:noreply, assign(socket, active_section: section)}
  end


  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end


  def handle_event("save_changes_profile", %{"form_data" => form_data}, socket) do
    restraurant = socket.assigns.restaurant
    form_data =
      if uploaded_files = List.first(upload_files(socket)) do
        form_data
        |> Map.put("profile_pic", uploaded_files)
      else
        form_data
        |> Map.put("photo_url" , "https://via.placeholder.com/150")
      end


    case Shops.update_restraurent(restraurant.id, form_data) do
      {:ok, _updated_restaurant} ->

        socket=
          socket
          |> put_flash(:info, "Profile updated successfully.")
          |> push_navigate(to: ~p"/restraurents/profile")

        {:noreply, socket}

      {:error, changeset} ->
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
  <div class="">
  <.live_component module={NavbarComponent} id={0}/>

  <div class="max-w-screen-lg mx-auto p-4">
    <div class="flex flex-col sm:flex-row items-center gap-4">
        <div class="w-full sm:w-1/3 h-72 bg-cover bg-center rounded-lg" style={"background-image: url(#{@restaurant.profile_pic});"}></div>
        <div class="w-full sm:w-2/3 flex flex-col gap-2">
            <div class="text-2xl font-semibold"><%=@restaurant.name%></div>
            <div class="text-lg text-gray-700">Rating: 4.5</div>
            <div class="text-gray-600">Address: <%=@restaurant.address%></div>
            <div class="text-gray-600">Phone: <%=@restaurant.phone%></div>
            <div class="text-gray-600">Email: <%=@restaurant.email%></div>
            <div class="text-gray-600">Open now: 11am – 9:30pm (Today)</div>
            <.button phx-click={show_modal("edit_profile")} class="w-fit mt-4 px-4 py-3 bg-blue-500 text-white rounded-lg hover:bg-black-600">Edit Profile</.button>
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
            <.live_component module={OverviewLive} id={0}/>
        <% end %>

        <%= if @active_section == "reviews" do %>
            <h2 class="text-2xl font-bold mb-4">Customers Reviews</h2>
            <.live_component module={ReviewLive} id={0} user={1} user_id={@restaurant.id} restraurant_id={@restaurant.id}/>
        <% end %>

        <%= if @active_section == "photos" do %>
            <.live_component module={PhotosLive} id={@restaurant.id} user={1} userdetails={@restaurant}/>
        <% end %>

        <%= if @active_section == "menu" do %>
            <.live_component module={MenuLive} id={@restaurant.id} cart_id={@cart_id} user={0} userdetails={@restaurant}/>
        <% end %>
      </div>
      </div>
    </div>
    <.live_component module={FooterComponent} id={0}/>
    <.modal id="edit_profile">
    <div class="">
        <h2 class="text-center font-bold"> Edit Details</h2>
        <.simple_form  for={@form_data} phx-submit="save_changes_profile" phx-change="validate" class="flex-col gap-2 items-center mb-4">
        <div class="mb-4">
            <.input type="text" label="Name" field={@form_data[:name]} class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="example@shop.com"/>
        </div>

        <div class="mb-4">
            <.input type="text" label="Address" field={@form_data[:address]} class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="example@shop.com"/>
        </div>

        <%!-- <div class="mb-4">
            <.input type="textarea" label="Description" field={@form_data[:name]} class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="example@shop.com"/>
        </div> --%>

        <div class="mb-4">
            <.input type="number" label="Phone" field={@form_data[:phone]} class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="example@shop.com"/>
        </div>

        <%!-- <div class="mb-4">
            <label class="block text-gray-700">Open Hours</label>
            <input type="text" id="email" name="item_open" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="example@shop.com">
        </div> --%>

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
