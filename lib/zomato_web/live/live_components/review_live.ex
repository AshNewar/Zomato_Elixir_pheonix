defmodule ZomatoWeb.LiveComponents.ReviewLive do
      alias Zomato.Reviews
  use ZomatoWeb, :live_component

  def update(assigns, socket) do
    reviews =
      if assigns.id == 1 do
        Reviews.get_review_user_id(assigns.user_id)
      else
        Reviews.get_review_restaurant_id(assigns.restraurant_id)
      end

    socket =
      socket
      |> assign(:reviews, reviews)

    {:ok, assign(socket, assigns)}
  end


  def handle_event("submit_review", params, socket) do

    case Reviews.create_review(params, socket.assigns.user_id, socket.assigns.restraurant_id) do
      {:ok, _review} ->
        Process.send_after(self(), :clear_flash, 2500)
        socket =
          socket
          |> put_flash(:info, "Review submitted successfully")
          |> push_navigate(to: ~p"/warehouse/restraurents/details/#{socket.assigns.restraurant_id}")

          {:noreply, socket}
      {:error, changeset} ->
        IO.inspect(changeset , label: "Something Eror")
        {:noreply, put_flash(socket, :error, "Failed to submit review")}
    end
  end


  def render(assigns) do
    ~H"""
     <div id="reviews" class="section mt-8">
            <div class="flex justify-between items-center">
              <div class="flex justify-between items-center mb-4">
                <select class="border border-gray-300 rounded px-3 py-2 text-sm" aria-label="Sort reviews">
                  <option value="latest">Sort by: Latest</option>
                  <option value="highest">Sort by: Highest Rating</option>
                  <option value="lowest">Sort by: Lowest Rating</option>
                </select>
              </div>
              <%= if @user == 0 do %>
              <button phx-click={show_modal("add_review")} class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500">Add Review</button>
              <% end %>
            </div>

            <div class="space-y-4">
              <%= for review <- @reviews do %>
              <div class="bg-white border border-gray-300 rounded-lg p-4 shadow-sm">
                <div class="flex items-center">
                  <div class="bg-blue-500 text-white rounded-full h-10 w-10 flex items-center justify-center">A</div>
                  <div class="ml-3">
                    <p class="font-bold text-gray-800"><%= review.user.name %></p>
                    <p class="text-sm text-gray-500"><%= review.inserted_at %></p>
                  </div>
                </div>
                <div class="mb-3">
                  <p class="text-gray-700"><%= review.description %></p>
                </div>
                <div class="flex items-center justify-between">
                  <div class="flex items-center space-x-2">
                    <button class="flex items-center text-gray-600 hover:text-blue-500">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" width="15" height="15">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M6.633 10.25c.806 0 1.533-.446 2.031-1.08a9.041 9.041 0 0 1 2.861-2.4c.723-.384 1.35-.956 1.653-1.715a4.498 4.498 0 0 0 .322-1.672V2.75a.75.75 0 0 1 .75-.75 2.25 2.25 0 0 1 2.25 2.25c0 1.152-.26 2.243-.723 3.218-.266.558.107 1.282.725 1.282m0 0h3.126c1.026 0 1.945.694 2.054 1.715.045.422.068.85.068 1.285a11.95 11.95 0 0 1-2.649 7.521c-.388.482-.987.729-1.605.729H13.48c-.483 0-.964-.078-1.423-.23l-3.114-1.04a4.501 4.501 0 0 0-1.423-.23H5.904m10.598-9.75H14.25M5.904 18.5c.083.205.173.405.27.602.197.4-.078.898-.523.898h-.908c-.889 0-1.713-.518-1.972-1.368a12 12 0 0 1-.521-3.507c0-1.553.295-3.036.831-4.398C3.387 9.953 4.167 9.5 5 9.5h1.053c.472 0 .745.556.5.96a8.958 8.958 0 0 0-1.302 4.665c0 1.194.232 2.333.654 3.375Z" />
                    </svg>

                      <span class="ml-1">Like</span>
                    </button>

                  </div>
                  <p class="text-sm text-gray-500">
                    Rating:
                    <%= for _ <- 1..review.rate do %>
                      ⭐
                    <% end %>
                  </p>

                </div>
              </div>
              <% end %>
              <!-- Additional Review Boxes as needed -->
              <!-- Example of another review box -->
            </div>

            <.modal id="add_review">
              <h2 class="text-2xl font-bold mb-4">Submit Your Review</h2>

              <form
                phx-submit="submit_review"
                class="space-y-4"
                phx-target={@myself}
              >
                <!-- Rating Section -->
                <div class="flex items-center space-x-2">
                  <label for="rate" class="block text-gray-700 font-medium">Rating</label>
                  <select id="rate" name="rate" class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500">
                    <option value="" disabled selected>Select a rating</option>
                    <option value="1">1 Star</option>
                    <option value="2">2 Stars</option>
                    <option value="3">3 Stars</option>
                    <option value="4">4 Stars</option>
                    <option value="5">5 Stars</option>
                  </select>
                </div>

                <!-- Description Section -->
                <div>
                  <label for="description" class="block text-gray-700 font-medium">Review</label>
                  <textarea
                    id="description"
                    name="description"
                    rows="4"
                    class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Write your review here..."
                  ></textarea>
                </div>

                <!-- Submit Button -->
                <div>
                  <button
                    type="submit"
                    class="w-full bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                    Submit Review
                  </button>
                </div>
              </form>


            </.modal>
          </div>
    """

  end

end
