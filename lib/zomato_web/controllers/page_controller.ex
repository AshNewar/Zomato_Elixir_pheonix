defmodule ZomatoWeb.PageControllerLive do
      alias Zomato.Orders
      alias Zomato.Items
      alias Zomato.Shops
      alias Zomato.Accounts.User
      alias Zomato.Accounts
      alias ZomatoWeb.FooterComponent
      use ZomatoWeb, :live_view


  def mount(_params, session, socket) do

    socket =
      if user_token = session["user_token"] do
        user = Accounts.get_user_by_session_token(user_token)
        assign(socket, :current_user, user)
      else
        assign(socket, :current_user, nil)
      end


    email = Phoenix.Flash.get(socket.assigns.flash, :email)

    changeset = Accounts.change_user_registration(%User{})

    changeset = if email do
      Ecto.Changeset.change(changeset, %{"email" => email})
    else
      changeset
    end

    best_restaurants = Shops.get_best_restaurents()
    best_item = Items.get_item_with_highest_orders()

    leader_board = Orders.top_users_by_orders()
    # IO.inspect(leader_board, label: "Leader Board")

    socket =
      socket
      |> assign(best_restaurants: best_restaurants)
      |> assign(best_item: best_item)
      |> assign(leader_board: leader_board)
      |> assign(trigger_submit: false, check_errors: false, search_results: nil)
      |> assign_form(changeset) # Updates socket with form changeset


    {:ok, socket, temporary_assigns: [form: nil]}

  end

  def handle_event("search_page", %{"id" => id}, socket) do
    {:noreply, redirect(socket, to: ~p"/warehouse/restraurents/details/#{id}")}
  end



  def handle_event("search_inputs", %{"search" => query}, socket) do
    IO.inspect(query, label: "Search Query")
    search_results = Shops.search_by_name(query)
    IO.inspect(search_results, label: "Search Results")

    {:noreply, assign(socket, search_results: search_results)}
  end


  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/warehouse/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end






  def render(assigns) do
    ~H"""
    <.flash_group flash={@flash} />
    <header>
      <nav>
        <div class="user-icon">
          <i data-feather="user"></i>
        </div>
        <div class="left">
          <div class="nav-item">
            <i data-feather="smartphone"></i>
            <a href="#">Get the app</a>
          </div>
        </div>
        <div class="right gap-8 items-center">

          <%= if @current_user do %>
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

              <.link class="nav-item" phx-click={show_modal("leader_board")}>
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" width="20" height="20">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 21a9.004 9.004 0 0 0 8.716-6.747M12 21a9.004 9.004 0 0 1-8.716-6.747M12 21c2.485 0 4.5-4.03 4.5-9S14.485 3 12 3m0 18c-2.485 0-4.5-4.03-4.5-9S9.515 3 12 3m0 0a8.997 8.997 0 0 1 7.843 4.582M12 3a8.997 8.997 0 0 0-7.843 4.582m15.686 0A11.953 11.953 0 0 1 12 10.5c-2.998 0-5.74-1.1-7.843-2.918m15.686 0A8.959 8.959 0 0 1 21 12c0 .778-.099 1.533-.284 2.253m0 0A17.919 17.919 0 0 1 12 16.5c-3.162 0-6.133-.815-8.716-2.247m0 0A9.015 9.015 0 0 1 3 12c0-1.605.42-3.113 1.157-4.418" />
                </svg>
              </.link>
              <.link
                href={~p"/warehouse/users/log_out"}
                method="delete"
                class="nav-item"
              >
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" width="20" height="20">
                <path strokeLinecap="round" strokeLinejoin="round" d="M8.25 9V5.25A2.25 2.25 0 0 1 10.5 3h6a2.25 2.25 0 0 1 2.25 2.25v13.5A2.25 2.25 0 0 1 16.5 21h-6a2.25 2.25 0 0 1-2.25-2.25V15m-3 0-3-3m0 0 3-3m-3 3H15" />
              </svg>

              </.link>
          <% else %>

          <div class="nav-item">
            <a href={~p"/restraurents/new"}>Add restaurant</a>
          </div>
          <div class="nav-item">
            <.link phx-click={show_modal("login_page")}>Log in</.link>
          </div>
          <div class="nav-item">
            <.link phx-click={show_modal("register_page")}>Register</.link>
          </div>
        <% end %>

        </div>
      </nav>
    </header>

    <main class="main_class">
      <img
        class="bg-image"
        src="https://b.zmtcdn.com/web_assets/81f3ff974d82520780078ba1cfbd453a1583259680.png"
      />
      <div class="top">
        <div class="center-content">
          <img
            class="main-logo"
            src={~p"/images/logo.png"}
            alt="Zomato Logo"
          />
          <h1>
            Discover the best food & drinks
            <span class="place">Near You</span>
          </h1>
          <div class="search_container">
            <%!--  --%>
            <div class="search flex flex-col ">
              <div class="flex justify-center items-center px-4 sm:px-2 py-6 bg-white rounded-lg shadow-md mt-2">
              <div class="search_icon">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" width="20" height="20">
                  <path strokeLinecap="round" strokeLinejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
                </svg>


              </div>
              <form phx-change="search_inputs" class="flex-grow flex justify-center items-center">
                <input
                  phx-debounce="300"
                  name="search"
                  placeholder="Search for restaurant, cuisine or a dish"
                  class="search_box w-full border outline-none rounded-lg p-2 "
                  value=""
                />
              </form>
              </div>
              <div class="search_results_container">
                <%= if @search_results do %>
                  <ul class="w-full bg-white border border-gray-300 rounded-lg shadow-md mt-2 cursor-pointer z-100">
                    <%= for result <- @search_results do %>
                      <li phx-click="search_page" phx-value-id={result.id} class="py-2 px-4 hover:bg-gray-100"><%= result.name %></li>
                    <% end %>
                  </ul>
                <% end %>
              </div>


            </div>
          </div>


        </div>
      </div>
      <div class="main-body">
        <div class="options">
          <div class="option">
            <div class="image">
              <img
                src="https://b.zmtcdn.com/webFrontend/e5b8785c257af2a7f354f1addaf37e4e1647364814.jpeg?output-format=webp&fit=around|402:360&crop=402:360;*,*"
              />
            </div>
            <div class="info">
              <p class="title">Order Online</p>
              <p class="description">Stay home and order on your doorstep</p>
            </div>
          </div>

          <div class="option">
            <div class="image">
              <img
                src="https://b.zmtcdn.com/webFrontend/d026b357feb0d63c997549f6398da8cc1647364915.jpeg?output-format=webp&fit=around|402:360&crop=402:360;*,*"
              />
            </div>
            <div class="info">
              <p class="title">Dining</p>
              <p class="description">View the city's favorite dining venues</p>
            </div>
          </div>

          <div class="option">
            <div class="image">
              <img
                src="https://b.zmtcdn.com/webFrontend/d9d80ef91cb552e3fdfadb3d4f4379761647365057.jpeg?output-format=webp&fit=around|402:360&crop=402:360;*,*"
              />
            </div>
            <div class="info">
              <p class="title">Nightlife and Clubs</p>
              <p class="description">
                Explore the city's top nightlife outlets
              </p>
            </div>
          </div>
        </div>

        <div class="collections">
          <h2 class="heading-2">Collections</h2>
          <div class="desc-see-more">
            <h6 class="heading-6">
              Explore curated lists of top restaurants, cafes, pubs, and bars in
              Near You, based on trends
            </h6>
          </div>

          <section class="collections-list">
            <%= for restaurant <- @best_restaurants do %>
            <div class="collection">
                <.link href={~p"/warehouse/restraurents/details/#{restaurant.restraurent_id}"}>
                  <%= if restaurant.profile_pic == nil do %>
                    <div class="image">
                      <img src="https://b.zmtcdn.com/data/collections/a1bafc59f9aa67998b9f8de61b9abbd4_1680160970.png?output-format=webp" />
                    </div>
                  <% else %>
                    <div class="image">
                      <img src={restaurant.profile_pic} />
                    </div>
                  <% end %>

                  <div class="overlay">
                    <div class="overlay-info">
                      <%= restaurant.name %>
                      <div class="places">
                        <%= for _ <- 1..Decimal.to_integer(Decimal.round(restaurant.avg_rating,0)) do %>
                          ⭐
                        <% end %>
                      </div>
                    </div>
                  </div>
                </.link>
              </div>

            <% end %>




          </section>
        </div>


        <div class="collections">
          <h2 class="heading-2">Trending Foods</h2>
          <div class="desc-see-more">
            <h6 class="heading-6">
              Explore the Best Food , EveryOne is Enjoying
            </h6>
          </div>

          <section class="collections-list">
            <%= for item <- @best_item do %>
            <div class="collection">
                  <%= if item.photo_url == nil do %>
                    <div class="image">
                      <img src="https://b.zmtcdn.com/data/collections/a1bafc59f9aa67998b9f8de61b9abbd4_1680160970.png?output-format=webp" />
                    </div>
                  <% else %>
                    <div class="image">
                      <img src={item.photo_url} />
                    </div>
                  <% end %>

                  <div class="overlay">
                    <div class="overlay-info">
                      <%= item.name %>
                      <div class="place">
                       $ <%= item.price %>
                      </div>
                      <%= item.restaurant.name %>
                    </div>
                  </div>
              </div>

            <% end %>




          </section>
        </div>

        <section class="popular-localities">
          <div class="title">
            Popular localities in and around
            <span class="city-name">Near You</span>
          </div>
          <div class="localities">
            <div class="locality">
              <div class="locality-info">
                <div class="locality-title">Connaught Place</div>
                <div class="locality-description">252 Places</div>
              </div>
              <i class="fa fa-chevron-right"></i>
            </div>

            <div class="locality">
              <div class="locality-info">
                <div class="locality-title">Sector 29</div>
                <div class="locality-description">144 Places</div>
              </div>
              <i class="fa fa-chevron-right"></i>
            </div>

            <div class="locality">
              <div class="locality-info">
                <div class="locality-title">Sector 18, Noida</div>
                <div class="locality-description">205 Places</div>
              </div>
              <i class="fa fa-chevron-right"></i>
            </div>

            <div class="locality">
              <div class="locality-info">
                <div class="locality-title">Rajouri Garden</div>
                <div class="locality-description">296 Places</div>
              </div>
              <i class="fa fa-chevron-right"></i>
            </div>

            <div class="locality">
              <div class="locality-info">
                <div class="locality-title">Saket</div>
                <div class="locality-description">307 Places</div>
              </div>
              <i class="fa fa-chevron-right"></i>
            </div>

            <div class="locality">
              <div class="locality-info">
                <div class="locality-title">DLF Cyber City</div>
                <div class="locality-description">153 Places</div>
              </div>
              <i class="fa fa-chevron-right"></i>
            </div>

            <div class="locality">
              <div class="locality-info">
                <div class="locality-title">Golf Course Road</div>
                <div class="locality-description">154 Places</div>
              </div>
              <i class="fa fa-chevron-right"></i>
            </div>

            <div class="locality">
              <div class="locality-info">
                <div class="locality-title">DLF Phase 4</div>
                <div class="locality-description">221 Places</div>
              </div>
              <i class="fa fa-chevron-right"></i>
            </div>

            <div class="locality">
              <div class="center">
                see more
                <i class="fa fa-chevron-down"></i>
              </div>
            </div>
          </div>
        </section>
      </div>
      <section class="app-section">
        <div class="content">
          <div class="phone-image">
            <img
              src="https://b.zmtcdn.com/data/o2_assets/f773629053b24263e69f601925790f301680693809.png"
            />
          </div>
          <div class="app-info">
            <div class="phone-title">Get the Zomato app</div>
            <div class="app-description">
              We will send you a link, open it on your phone to download the app
            </div>

            <section class="option-selector">
              <div class="radio-option">
                <input id="email" type="radio" name="radio" checked />
                <label for="email">Email</label>
              </div>
              <div class="radio-option">
                <input id="phone" type="radio" name="radio" />
                <label for="phone">Phone</label>
              </div>
            </section>

            <section class="email-input">
              <input type="email" placeholder="Email" class="email" />
              <button class="btn">Share App Link</button>
            </section>

            <section class="store">
              <div class="caption">Download app from</div>
              <div class="buttons">
                <img
                  src="https://b.zmtcdn.com/data/webuikit/23e930757c3df49840c482a8638bf5c31556001144.png"
                />
                <img
                  src="https://b.zmtcdn.com/data/webuikit/9f0c85a5e33adb783fa0aef667075f9e1556003622.png"
                />
              </div>
            </section>
          </div>
        </div>
      </section>


    </main>
    <.live_component module={FooterComponent} id={0}/>
    <.modal id="login_page">
    <.header class="text-center text-2xl font-bold">
        Log in to your account
        <:subtitle>
          <p class="text-gray-600 text-sm mt-2">
            Don't have an account?
            <.link phx-click={hide_modal("login_page") |> show_modal("register_page")} class="font-semibold text-brand hover:underline">
              Sign up
            </.link>
            for an account now.
          </p>
        </:subtitle>
      </.header>

    <.simple_form for={@form} id="login_form" action={~p"/warehouse/users/log_in"} phx-update="ignore" class="mt-6">
      <.input field={@form[:email]} type="email" label="Email" required />
      <.input field={@form[:password]} type="password" label="Password" required />

      <:actions>
        <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
        <.link href={~p"/warehouse/users/reset_password"} class="text-sm font-semibold text-brand hover:underline">
          Forgot your password?
        </.link>
      </:actions>
      <:actions>
        <.button phx-disable-with="Logging in..." class="w-full mt-4 bg-brand text-white hover:bg-brand-dark">
          Log in <span aria-hidden="true">→</span>
        </.button>
      </:actions>
    </.simple_form>


    </.modal>

    <.modal id="register_page">
    <.header class="text-center text-2xl font-bold">
      Register for an account
      <:subtitle>
        <p class="text-gray-600 text-sm mt-2">
          Already registered?
          <.link phx-click={hide_modal("register_page") |> show_modal("login_page")} class="font-semibold text-brand hover:underline">
            Log in
          </.link>
          to your account now.
        </p>
      </:subtitle>
    </.header>

    <.simple_form
      for={@form}
      id="registration_form"
      phx-submit="save"
      phx-change="validate"
      phx-trigger-action={@trigger_submit}
      action={~p"/warehouse/users/log_in?_action=registered"}
      method="post"
      class="mt-6"
    >
      <.error :if={@check_errors}>
        Oops, something went wrong! Please check the errors below.
      </.error>

      <.input field={@form[:email]} type="email" label="Email" required />
      <.input field={@form[:password]} type="password" label="Password" required />
      <.input field={@form[:name]} type="text" label="Name" required />
      <.input field={@form[:phone]} type="text" label="Phone" required />
      <.input field={@form[:address]} type="text" label="Address" required />


      <:actions>
        <.button phx-disable-with="Creating account..." class="w-full bg-brand text-white hover:bg-brand-dark">
          Create an account
        </.button>
      </:actions>
    </.simple_form>

    </.modal>

    <.modal id="leader_board">
    <h2 class="text-2xl font-bold mb-4">Zomato Point Leader Board</h2>

    <ul class="flex flex-col justify-center">
    <%= for user <- @leader_board do %>
    <.link href={~p"/warehouse/users/details/#{user.user_id}"}>
      <li class="flex items-center w-full border border-gray-300 rounded-lg p-2 mb-2 hover:bg-gray-100">
        <div class="w-10 h-10 rounded-full bg-gray-200 mr-2" style={"background-image: url('#{user.user_profile}'); background-size: cover;"}></div>
        <span class="text-gray-600 flex-grow font-bold"><%=user.user_name%></span>
        <span class="text-gray-700 font-semibold">Points <%=user.total_amount |> Kernel.*(0.1) |> Float.round(2)%></span>
      </li>
    </.link>
    <% end %>

    </ul>



    </.modal>


   """

  end
end
