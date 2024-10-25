defmodule ZomatoWeb.Restraurents.RestraurentMenuLive do
  alias ZomatoWeb.FooterComponent
  alias Zomato.Item
  alias Zomato.Shops
  alias Zomato.Items
  use ZomatoWeb, :live_view
  alias ZomatoWeb.NavbarComponent

  @impl true
  def mount(_params, %{"restraurent_token" => restraurent_token}=_session, socket) do
    restaurant = Shops.get_restraurent_by_session_token(restraurent_token)  # Assuming you have a way to get the restaurant ID from the session
    items = Zomato.Items.list_items_by_restaurant(restaurant.id)
    form =
      %Item{}
      |> Items.change_item(%{})
      |> to_form(as: "form_data")

    socket =
      socket
      |> assign(:uploaded_files,[])
      |> assign(:form_data, form)
      |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png), max_entries: 2)

    {:ok, assign(socket, items: items, selected_id: 0 , restaurant_id: restaurant.id, item: %{},show_edit_modal: false)}
  end

  @impl true
  def handle_event("save", %{"form_data" => form_data}, socket) do
    form_data =
      if uploaded_files = List.first(upload_files(socket)) do
        form_data
        |> Map.put("photo_url", uploaded_files)
      else
        form_data
        |> Map.put("photo_url" , "https://via.placeholder.com/150")
      end

    case Items.create_item(form_data, socket.assigns.restaurant_id) do
      {:ok, _item} ->
        {:noreply,
         socket
         |> Phoenix.LiveView.put_flash(:info, "Item created successfully.")
         |> Phoenix.LiveView.redirect(to: ~p"/restraurents/menu")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event("edit_items", %{"id" => id}, socket) do
    item = Items.get_item!(id) # Fetch the item based on the ID passed
    {:noreply, assign(socket, item: item, show_edit_modal: true)}
  end

  def handle_event("cancel", _, socket) do
    {:noreply, assign(socket, show_edit_modal: false, item: %{})}
  end

  @impl true
  def handle_event("save_changes", %{"form_data" => form_data}, socket) do
    form_data =
      if uploaded_files = List.first(upload_files(socket)) do
        form_data
        |> Map.put("photo_url", uploaded_files)
      else
        form_data
      end

    IO.inspect(form_data, label: "form_data")

    case Items.update_item(socket.assigns.item.id, form_data) do
      {:ok, _item} ->
        items = Items.list_items_by_restaurant(socket.assigns.restaurant_id) # Fetch updated items list if needed
        {:noreply, assign(socket, items: items, show_edit_modal: false)}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    {:noreply, assign(socket, selected_id: id)}
  end

  @impl true
  def handle_event("delete_item", _, socket) do
    case Items.delete_item(socket.assigns.selected_id) do
      {:ok, _deleted_item} ->
        items = Items.list_items_by_restaurant(socket.assigns.restaurant_id)

        {:noreply,
        socket
        |> assign(items: items, show_edit_modal: false)
        |> Phoenix.LiveView.put_flash(:info, "Item deleted successfully")
        |> Phoenix.LiveView.redirect(to: ~p"/restraurents/menu")}

      {:error, _reason} ->
        {:noreply, assign(socket, error: "Failed to delete item")}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("validate",_, socket) do

    {:noreply, socket}
  end



  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
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
    <div class="bg-gray-100">
      <div class="flex-col flex h-screen">
        <.live_component module={NavbarComponent} id={0}/>

        <div class="flex-1 p-6">
          <h2 class="text-3xl font-semibold mb-6">Menu Items</h2>

          <div class="mb-4">
            <button phx-click={show_modal("create_item")} class="bg-green-600 text-white font-bold py-2 px-4 rounded hover:bg-green-700">
              Add Item
            </button>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-6">
            <%= for item <- @items do %>
              <div class="bg-white rounded-lg shadow-md p-4">
                <div class="mb-4">
                  <img id="item-image" src={item.photo_url} alt="Menu Item Image" class="w-full h-32 object-cover rounded-md mb-2" />
                </div>
                <h3 class="text-xl font-semibold mb-2"><%= item.name %></h3>
                <p class="text-gray-600 font-bold mb-2">Price: $<%= item.price %></p>
                <p class="text-gray-600 mb-4"><%= item.description %></p>

                <div class="flex justify-between">
                  <button phx-click={JS.push("edit_items") |> show_modal("edit_item")} phx-value-id={item.id} class="bg-blue-600 text-white py-1 px-3 rounded hover:bg-blue-700">Edit</button>
                  <button phx-click={JS.push("delete") |> show_modal("delete_item")} phx-value-id={item.id} class="bg-red-600 text-white py-1 px-3 rounded hover:bg-red-700">Delete</button>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>

    <.modal id="delete_item">
            <h2 class="text-2xl font-bold mb-4">Confirm Deletion</h2>
            <p class="mb-4">Are you sure you want to delete this item?</p>
            <div class="flex justify-between">
              <button phx-click="delete_item"  class="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-700">
                Yes, Delete
              </button>
              <button phx-click={hide_modal("delete_item")}  class="bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-700">
                Cancel
              </button>
            </div>
    </.modal>

    <.modal id="create_item" >
        <h2 class="text-2xl font-semibold mb-4 text-center">Add Item Details</h2>
        <.simple_form  for={@form_data} phx-submit="save" phx-change="validate">
            <div class="mb-4">
              <.input type="text" label="Name" field={@form_data[:name]}  class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"  />
            </div>
            <div class="mb-4">
              <.input label="Description" field={@form_data[:description]} type="textarea" class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2" />
            </div>

            <div class="mb-4">
              <.input type="number" label="Price" field={@form_data[:price]}  class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"  />
            </div>

            <div class="mb-4">
            <.input type="text" label="Category" field={@form_data[:category]} id="item_category" step="0.01" class="mt-1 block w-full border border-gray-300 rounded-md p-2"  />
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

    </.modal>


    <%= if @item && @show_edit_modal do %>
    <.modal id="edit_item" show={@show_edit_modal}>
        <h2 class="text-2xl font-bold mb-4">Edit Item</h2>
          <.simple_form  for={@form_data} phx-submit="save_changes" phx-change="validate">
            <div class="mb-4">
              <.input type="text" label="Name" field={@form_data[:name]} value={@item.name} class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"  />
            </div>
            <div class="mb-4">
              <.input label="Description" field={@form_data[:description]} type="textarea" value={@item.description} class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2" />
            </div>

            <div class="mb-4">
              <.input type="number" label="Price" field={@form_data[:price]} value={@item.price} class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"  />
            </div>

            <div class="mb-4">
            <.input type="text" label="Category" field={@form_data[:category]} value={@item.category} id="item_category" step="0.01" class="mt-1 block w-full border border-gray-300 rounded-md p-2"  />
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

    </.modal>
    <% end %>
    <.live_component module={FooterComponent} id={0}/>


    """
  end




end
