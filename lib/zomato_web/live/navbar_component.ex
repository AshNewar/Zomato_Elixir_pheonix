defmodule ZomatoWeb.NavbarComponent do
  use ZomatoWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="bg-white shadow-md py-4 px-6 flex justify-center items-center">
      <!-- Dashboard Title on the Left with flex-grow to push nav to the far right -->
      <div class="flex-grow flex justify-center items-center text-3xl font-bold hidden md:block">
        Dashboard
      </div>


      <!-- Navigation Links on the Right -->
      <nav class="flex space-x-6 justify-end">
        <.link href="dashboard" class="text-gray-700 hover:bg-gray-200 py-2 px-4 rounded">Orders</.link>
        <.link href="profile" class="text-gray-700 hover:bg-gray-200 py-2 px-4 rounded">Edit Profile</.link>
        <.link href="menu" class="text-gray-700 hover:bg-gray-200 py-2 px-4 rounded">Change Menu</.link>
        <.link href={~p"/restraurents/restraurents/settings"} class="text-gray-700 hover:bg-gray-200 py-2 px-4 rounded">Settings</.link>
        <.link phx-click={show_modal("log_out")} class="text-gray-700 hover:bg-gray-200 py-2 px-4 rounded">Logout</.link>
      </nav>

      <.modal id="log_out">
      <h1>Are you sure you want to log out?</h1>
      <div class="flex px-6 py-6 justify-center items-center space-x-4 max-w-screen-sm mx-auto">
        <.link href="restraurents/log_out" method="delete" class="bg-lime-600 text-white font-semibold py-2 px-4 rounded-lg hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-opacity-50">
          Yes
        </.link>
        <.link phx-click={hide_modal("log_out")} class="bg-red-600 text-white font-semibold py-2 px-4 rounded-lg hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-opacity-50">
          No
        </.link>
      </div>

    </.modal>
    </div>

    """
  end
end
