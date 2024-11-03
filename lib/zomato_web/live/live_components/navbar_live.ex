defmodule ZomatoWeb.LiveComponents.NavbarLive do
  alias Zomato.Shops
  alias ZomatoWeb.LiveComponents.CartComponent
  use ZomatoWeb, :live_component

  @impl true
  def update(assigns, socket) do
    socket =
      socket |> assign(:search_results, nil)

    socket = assign(socket, assigns)

    {:ok, socket}
  end


  @impl true
  def handle_event("search", %{"search_input" => query}, socket) do
    search_results = Shops.search_by_name(query)
    {:noreply, assign(socket, :search_results, search_results)}
  end

  def handle_event("search_page", %{"id" => id}, socket) do
    {:noreply, redirect(socket, to: ~p"/warehouse/restraurents/details/#{id}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="nav_live" class="flex justify-between items-center mb-4 gap-4">
      <div class="hidden sm:flex items-center justify-center">
        <a href="/" class="flex">
          <img
            src="https://b.zmtcdn.com/web_assets/b40b97e677bc7b2ca77c58c61db266fe1603954218.png?fit=around|198:42&amp;crop=198:42;*,*"
            alt="Zomato logo"
            class="h-6 w-32"
          />
        </a>
      </div>

      <div class="flex-grow relative">

      <form class="flex-grow mx-4" phx-target={@myself} phx-change="search">
        <input
          type="text"
          class="w-full p-4 border border-gray-300 rounded-lg shadow-md outline-none"
          placeholder="Search"
          phx-debounce="300"
          name="search_input"
        >
      </form>

      <div class="search_results_container absolute px-4 w-full z-10">
        <%= if @search_results && length(@search_results) > 0 do %>
          <ul class="bg-white border border-gray-300 rounded-lg shadow-md mt-2 cursor-pointer">
            <%= for result <- @search_results do %>
              <li phx-click="search_page" phx-target={@myself} phx-value-id={result.id} class="py-2 px-4 hover:bg-gray-100"><%= result.name %></li>
            <% end %>
          </ul>
        <% end %>
      </div>

      </div>

      <.link   href={~p"/warehouse/users/settings"} class="nav-item">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" width="20" height="20">
                <path strokeLinecap="round" strokeLinejoin="round" d="M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.325.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 0 1 1.37.49l1.296 2.247a1.125 1.125 0 0 1-.26 1.431l-1.003.827c-.293.241-.438.613-.43.992a7.723 7.723 0 0 1 0 .255c-.008.378.137.75.43.991l1.004.827c.424.35.534.955.26 1.43l-1.298 2.247a1.125 1.125 0 0 1-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.47 6.47 0 0 1-.22.128c-.331.183-.581.495-.644.869l-.213 1.281c-.09.543-.56.94-1.11.94h-2.594c-.55 0-1.019-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 0 1-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 0 1-1.369-.49l-1.297-2.247a1.125 1.125 0 0 1 .26-1.431l1.004-.827c.292-.24.437-.613.43-.991a6.932 6.932 0 0 1 0-.255c.007-.38-.138-.751-.43-.992l-1.004-.827a1.125 1.125 0 0 1-.26-1.43l1.297-2.247a1.125 1.125 0 0 1 1.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.086.22-.128.332-.183.582-.495.644-.869l.214-1.28Z" />
                <path strokeLinecap="round" strokeLinejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
              </svg>
      </.link>
        <.link
        href={~p"/warehouse/users/dashboard"}
          class="nav-item"
        >
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" width="20" height="20">
            <path strokeLinecap="round" strokeLinejoin="round" d="M17.982 18.725A7.488 7.488 0 0 0 12 15.75a7.488 7.488 0 0 0-5.982 2.975m11.963 0a9 9 0 1 0-11.963 0m11.963 0A8.966 8.966 0 0 1 12 21a8.966 8.966 0 0 1-5.982-2.275M15 9.75a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
          </svg>

        </.link>

        <.link href={~p"/warehouse/users/chat?room_id=1"}>
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" width="20" height="20">
          <path strokeLinecap="round" strokeLinejoin="round" d="M8.625 9.75a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Zm0 0H8.25m4.125 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Zm0 0H12m4.125 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Zm0 0h-.375m-13.5 3.01c0 1.6 1.123 2.994 2.707 3.227 1.087.16 2.185.283 3.293.369V21l4.184-4.183a1.14 1.14 0 0 1 .778-.332 48.294 48.294 0 0 0 5.83-.498c1.585-.233 2.708-1.626 2.708-3.228V6.741c0-1.602-1.123-2.995-2.707-3.228A48.394 48.394 0 0 0 12 3c-2.392 0-4.744.175-7.043.513C3.373 3.746 2.25 5.14 2.25 6.741v6.018Z" />
        </svg>
        </.link>

        <.link phx-click={show_modal("cart")}>
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth="1.5" stroke="currentColor" width="20" height="20">
            <path strokeLinecap="round" strokeLinejoin="round" d="M2.25 3h1.386c.51 0 .955.343 1.087.835l.383 1.437M7.5 14.25a3 3 0 0 0-3 3h15.75m-12.75-3h11.218c1.121-2.3 2.1-4.684 2.924-7.138a60.114 60.114 0 0 0-16.536-1.84M7.5 14.25 5.106 5.272M6 20.25a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Zm12.75 0a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Z" />
          </svg>
        </.link>


      <.link
          method="delete"
          class="nav-item"
          phx-click={show_modal("log_out_nav")}
        >
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" width="20" height="20">
          <path strokeLinecap="round" strokeLinejoin="round" d="M8.25 9V5.25A2.25 2.25 0 0 1 10.5 3h6a2.25 2.25 0 0 1 2.25 2.25v13.5A2.25 2.25 0 0 1 16.5 21h-6a2.25 2.25 0 0 1-2.25-2.25V15m-3 0-3-3m0 0 3-3m-3 3H15" />
        </svg>

        </.link>
      <.modal id="cart">
        <.live_component module={CartComponent} id={@id} cart_id={@cart_id}/>
      </.modal>

      <.modal id="log_out_nav">
        <h1>Are you sure you want to log out?</h1>
        <div class="flex px-6 py-6 justify-center items-center space-x-4 max-w-screen-sm mx-auto">
          <.link href={~p"/warehouse/users/log_out"} method="delete" class="bg-lime-600 text-white font-semibold py-2 px-4 rounded-lg hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-opacity-50">
            Yes
          </.link>
          <.link phx-click={hide_modal("log_out_nav")} class="bg-red-600 text-white font-semibold py-2 px-4 rounded-lg hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-opacity-50">
            No
          </.link>
        </div>

    </.modal>
    </div>
    """
  end


end
