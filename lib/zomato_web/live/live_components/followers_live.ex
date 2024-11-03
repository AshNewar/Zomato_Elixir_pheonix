defmodule ZomatoWeb.LiveComponents.FollowersLive do
  use ZomatoWeb, :live_component

  def mount(_params, _session, socket) do
    {:ok, assign(socket, cur_section: "following")}  
  end

  def handle_event("change_sec", %{"section" => section}, socket) do
    {:noreply, assign(socket, cur_section: section)}
  end

  def render(assigns) do
    ~H"""
    <div id="myFollowers" class="section">
      <div class="bg-white rounded-lg shadow-md p-6 mb-6">
        <!-- Followers Section -->
        <h2 class="text-2xl font-semibold mb-4">Followers</h2>
        <div class="flex space-x-4 mb-4">
          <button phx-click="change_sec" phx-value-section="following" id="followingBtn" class="toggle-button bg-white text-gray-700 py-2 px-4 rounded border border-red-300 hover:bg-red-600">Following</button>
          <button phx-click="change_sec" phx-value-section="followers" id="followersBtn" class="toggle-button bg-white text-gray-700 py-2 px-4 rounded border border-red-300 hover:bg-gray-100">Followers</button>
        </div>

        <%= if @cur_section == "following" do %>
          <div id="followingSection" class="follower-section">
            <ul class="flex flex-wrap justify-center">
              <li class="flex items-center mb-2 w-1/2 sm:w-1/3 md:w-1/4 border border-gray-300 rounded-lg p-2 mx-1">
                <div class="w-8 h-8 rounded-full bg-gray-200 mr-2" style="background-image: url('https://via.placeholder.com/50'); background-size: cover;"></div>
                <span class="text-gray-600">User 1</span>
              </li>
              <li class="flex items-center mb-2 w-1/2 sm:w-1/3 md:w-1/4 border border-gray-300 rounded-lg p-2 mx-1">
                <div class="w-8 h-8 rounded-full bg-gray-200 mr-2" style="background-image: url('https://via.placeholder.com/50'); background-size: cover;"></div>
                <span class="text-gray-600">User 2</span>
              </li>
              <li class="flex items-center mb-2 w-1/2 sm:w-1/3 md:w-1/4 border border-gray-300 rounded-lg p-2 mx-1">
                <div class="w-8 h-8 rounded-full bg-gray-200 mr-2" style="background-image: url('https://via.placeholder.com/50'); background-size: cover;"></div>
                <span class="text-gray-600">User 3</span>
              </li>
            </ul>
          </div>
        <% end %>

        <%= if @cur_section == "followers" do %>
          <div id="followersSection" class="follower-section">
            <ul class="flex flex-wrap justify-center">
              <li class="flex items-center mb-2 w-1/2 sm:w-1/3 md:w-1/4 border border-gray-300 rounded-lg p-2 mx-1">
                <div class="w-8 h-8 rounded-full bg-gray-200 mr-2" style="background-image: url('https://via.placeholder.com/50'); background-size: cover;"></div>
                <span class="text-gray-600">Follower 1</span>
              </li>
              <li class="flex items-center mb-2 w-1/2 sm:w-1/3 md:w-1/4 border border-gray-300 rounded-lg p-2 mx-1">
                <div class="w-8 h-8 rounded-full bg-gray-200 mr-2" style="background-image: url('https://via.placeholder.com/50'); background-size: cover;"></div>
                <span class="text-gray-600">Follower 2</span>
              </li>
              <li class="flex items-center mb-2 w-1/2 sm:w-1/3 md:w-1/4 border border-gray-300 rounded-lg p-2 mx-1">
                <div class="w-8 h-8 rounded-full bg-gray-200 mr-2" style="background-image: url('https://via.placeholder.com/50'); background-size: cover;"></div>
                <span class="text-gray-600">Follower 3</span>
              </li>
            </ul>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
