defmodule ZomatoWeb.LiveComponents.PhotosLive do
      alias Zomato.Gallery
  use ZomatoWeb, :live_component

  @impl true
  def update(assigns, socket) do
    IO.inspect(assigns, label: "assigns")
    photos =
      if assigns.user == 1 do
        Gallery.get_photo_by_restaurant_id(assigns.id)
      else
        Gallery.get_photo_by_user_id(assigns.id)
      end

      socket =
        socket
        |> assign(:photos, photos)
        |> assign(:uploaded_files,[])
        |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png), max_entries: 1)



        {:ok, assign(socket, assigns)}
  end


      @impl true
      def handle_event("validate",_, socket) do
        {:noreply, socket}
      end



      @impl true
      def handle_event("cancel-upload", %{"ref" => ref}, socket) do
        {:noreply, cancel_upload(socket, :avatar, ref)}
      end


      def handle_event("submit_photos", _unsigned_params, socket) do
        user_done=
          if socket.assigns.user == 1 do
            true
          else
            false
          end
        photo_url = %{"url" => List.first(upload_files(socket)), "user_done" => user_done}

        case Gallery.create_photo(photo_url, socket.assigns.userdetails.id, socket.assigns.id) do
          {:ok, _review} ->
          Process.send_after(self(), :clear_flash, 2500)
          photos =
            if socket.assigns.user == 1 do
              Gallery.get_photo_by_restaurant_id(socket.assigns.id)
            else
              Gallery.get_photo_by_user_id(socket.assigns.id)
            end

            socket =
              socket
              |> assign(:photos, photos)
              |> put_flash(:info, "Photo Uploaded successfully")

              {:noreply, socket}
          {:error, changeset} ->
            IO.inspect(changeset , label: "Smething Error")
            {:noreply, put_flash(socket, :error, "Failed to submit Photo")}
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

      @impl true
  def render(assigns) do
    ~H"""
    <div id="photos" class="section mt-8 ">
    <div class="flex flex-wrap gap-6">
      <%= for photo <- @photos do %>
        <img src={photo.url} alt="Photo" class="w-64 h-64 rounded-lg object-cover">
      <% end %>
    </div>


            <%=if @user == 1 do %>
            <button phx-click={show_modal("add_photos")} class="bg-blue-600 flex justify-center items-center gap-2 text-white px-4 py-2 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 mt-6">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" width="20" height="20">
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v6m3-3H9m12 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
            </svg>Add Photos

            </button>
            <% end %>
            <.modal id="add_photos">
            <h2 class="text-2xl font-bold mb-4">Add Photos</h2>
            <form phx-change="validate" phx-target={@myself} phx-submit={JS.push("submit_photos") |> hide_modal("add_photos")} class="space-y-4">
                <.live_file_input upload={@uploads.avatar} class="block p-2 border border-gray-300 rounded-lg w-full"/>
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
                      <button type="button" phx-click="cancel-upload" phx-target={@myself} phx-value-ref={entry.ref} aria-label="cancel" class="text-red-600 text-2xl hover:text-red-800">&times;</button>
                    </article>
                  <% end %>

                  <%= for err <- upload_errors(@uploads.avatar) do %>
                    <p class="alert alert-danger text-red-600 font-medium"><%= error_to_string(err) %></p>
                  <% end %>
                </section>
                <button type="submit" phx-disable-with="Adding Photos ..." class="mt-2 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 w-full">Save Changes</button>
            </form>
          </.modal>

        </div>



    """
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"


end
