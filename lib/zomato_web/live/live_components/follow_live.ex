defmodule ZomatoWeb.LiveComponents.FollowLive do
      alias Zomato.Followers
  use ZomatoWeb, :live_component

  def update(assigns, socket) do

    followers = Followers.get_user_followers(assigns.id)
    following = Followers.get_user_following(assigns.id)

    random_user = Followers.get_random_users_not_followed_by(assigns.id)

    socket =
      socket
      |> assign(cur_section: "following")
      |> assign(random_user: random_user)
      |> assign(followers: followers)
      |> assign(following: following)
      |> assign(id: assigns.id)
      |> assign(show: assigns.show)

    {:ok, socket}

  end


  def handle_event("change_sec", %{"section" => section}, socket) do
    {:noreply, assign(socket, cur_section: section)}
  end

  def handle_event("remove_user", %{"id" => id}, socket) do
    Followers.unfollow_user(socket.assigns.id, id)
    followers = Followers.get_user_followers(socket.assigns.id)
    following = Followers.get_user_following(socket.assigns.id)

    socket = assign(socket, followers: followers, following: following)
    {:noreply, socket}
  end

  def handle_event("follow_user", %{"id" => id}, socket) do
    Followers.follow_user(socket.assigns.id, id)

    random_user = Followers.get_random_users_not_followed_by(socket.assigns.id)
    following = Followers.get_user_following(socket.assigns.id)

    socket = assign(socket, random_user: random_user, following: following)
    {:noreply, socket}

  end



  def render(assigns) do
    ~H"""
    <div>

    <div class="bg-white rounded-lg shadow-md p-6 mb-6">
      <%= if @cur_section == "following" do %>
        <h2 class="text-2xl font-semibold mb-4">Followings</h2>
      <% else %>
        <h2 class="text-2xl font-semibold mb-4">Followers</h2>
      <% end %>
        <div class="flex space-x-4 mb-4">
          <button phx-click="change_sec" phx-target={@myself} phx-value-section="following" class="toggle-button bg-white text-gray-700 py-2 px-4 rounded border border-red-300 hover:bg-red-600">Following</button>
          <button phx-click="change_sec"  phx-target={@myself} phx-value-section="followers" class="toggle-button bg-white text-gray-700 py-2 px-4 rounded border border-red-300 hover:bg-gray-100">Followers</button>
        </div>

        <%= if @cur_section == "following" do %>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">

          <%= for user <- @following do %>
            <div class="bg-white shadow-md rounded-lg p-4 flex items-center justify-between">
              <div class="flex items-center">
                <img class="w-12 h-12 rounded-full mr-4" src={user.profile_pic} alt="Profile Pic">
                <div>
                  <h2 class="text-lg font-semibold"><%= user.name%></h2>
                </div>
              </div>
              <%= if @show==0 do %>
              <button phx-target={@myself} phx-click="remove_user" phx-value-id={user.id} class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 transition">Remove</button>
              <% end %>
            </div>
          <% end %>

        </div>
        <% else %>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">

          <%= for user <- @followers do %>
            <div class="bg-white shadow-md rounded-lg p-4 flex items-center justify-between">
              <div class="flex items-center">
                <img class="w-12 h-12 rounded-full mr-4" src={user.profile_pic} alt="Profile Pic">
                <div>
                  <h2 class="text-lg font-semibold"><%= user.name%></h2>
                </div>
              </div>
            </div>
          <% end %>

    </div>
        <% end %>
    </div>
    <%= if @show==0 do %>
    <div>
      <div class="container mx-auto p-6">
        <h1 class="text-3xl font-bold mb-6 text-center">Suggested Users</h1>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <%= for user <- @random_user do %>
          <div class="bg-white shadow-md rounded-lg p-4 flex items-center justify-between">
            <div class="flex items-center">
              <img class="w-12 h-12 rounded-full mr-4" src={user.profile_pic} alt="Profile Pic">
              <div>
                <h2 class="text-lg font-semibold"><%= user.name%></h2>
              </div>
            </div>
            <button phx-target={@myself} phx-click="follow_user" phx-value-id={user.id}  class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 transition">Follow</button>
          </div>
        <% end %>
        </div>
      </div>
    </div>
    <% end %>
    </div>
    """
  end
end
