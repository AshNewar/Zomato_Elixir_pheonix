defmodule ZomatoWeb.Restraurents.RestraurentHomeLive do
      alias ZomatoWeb.FooterComponent
      alias Zomato.Shops
      alias Zomato.Shops.Restraurent
      use ZomatoWeb, :live_view


  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)

    changeset = Shops.change_restraurent_registration(%Restraurent{})

    changeset = if email do
      Ecto.Changeset.change(changeset, %{"email" => email})
    else
      changeset
    end

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset) # Updates socket with form changeset

    {:ok, socket, temporary_assigns: [form: nil]}
  end



  def handle_event("save", %{"restraurent" => restraurent_params}, socket) do
    IO.inspect(restraurent_params, label: "restraurent_params")

    case Shops.register_restraurent(restraurent_params) do
      {:ok, restraurent} ->
        {:ok, _} =
          Shops.deliver_restraurent_confirmation_instructions(
            restraurent,
            &url(~p"/restraurents/restraurents/confirm/#{&1}")
          )

        changeset = Shops.change_restraurent_registration(restraurent)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end



  def handle_event("validate", %{"restraurent" => restraurent_params}, socket) do
    changeset = Shops.change_restraurent_registration(%Restraurent{}, restraurent_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "restraurent")

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
            <a href={~p"/"}>Home</a>
          </div>
        </div>
      </nav>
    </header>

    <main>
      <img
        class="bg-image"
        src="https://b.zmtcdn.com/web_assets/81f3ff974d82520780078ba1cfbd453a1583259680.png"
      />
      <div class="top relative">
        <div class="center-content">
          <img
            class="main-logo"
            src={~p"/images/logo.png"}
            alt="Zomato Logo"
          />
          <h1 class="text-5xl px-6 py-6 font-bold text-white text-center">
          Partner with Zomato
          and grow your business
            <%!-- <span class="place">Near You</span> --%>
          </h1>
          <.link phx-click={show_modal("register")} class="bg-blue-800 text-white text-xl font-bold py-4 px-12 rounded-lg hover:bg-blue-400 focus:outline-none focus:ring-2 focus:ring-blue-300 focus:ring-opacity-50">
            Register Your Restaurant
        </.link>

        </div>
      </div>
      <h2 class="text-5xl font-bold text-center mb-10">Why Partner with Zomato?</h2>

      <div class="max-w-screen-lg m-auto grid gap-8 sm:grid-cols-1 md:grid-cols-2 lg:grid-cols-3 px-2">
        <!-- Card 1: Reach More Customers -->
        <div class="bg-white shadow-lg rounded-lg overflow-hidden">
            <div class="image h-66">
                <img
                    src="https://b.zmtcdn.com/webFrontend/e5b8785c257af2a7f354f1addaf37e4e1647364814.jpeg?output-format=webp&fit=around|402:360&crop=402:360;*,*"
                    alt="Reach More Customers"
                    class="w-full h-full object-cover"
                />
            </div>
            <div class="p-6">
                <h3 class="text-xl font-bold mb-2">Reach More Customers</h3>
                <p class="text-gray-700">Expand your customer base by tapping into Zomato’s vast user network, attracting diners right to your doorstep.</p>
            </div>
        </div>

        <!-- Card 2: Boost Brand Visibility -->
        <div class="bg-white shadow-lg rounded-lg overflow-hidden">
            <div class="image h-66">
                <img
                    src="https://b.zmtcdn.com/webFrontend/d026b357feb0d63c997549f6398da8cc1647364915.jpeg?output-format=webp&fit=around|402:360&crop=402:360;*,*"
                    alt="Boost Brand Visibility"
                    class="w-full h-full object-cover"
                />
            </div>
            <div class="p-6">
                <h3 class="text-xl font-bold mb-2">Boost Brand Visibility</h3>
                <p class="text-gray-700">Enhance your restaurant’s online presence and make it easier for potential customers to discover your unique offerings.</p>
            </div>
        </div>

        <!-- Card 3: Access Marketing Support -->
        <div class="bg-white shadow-lg rounded-lg overflow-hidden">
            <div class="image h-66">
                <img
                    src="https://b.zmtcdn.com/webFrontend/d9d80ef91cb552e3fdfadb3d4f4379761647365057.jpeg?output-format=webp&fit=around|402:360&crop=402:360;*,*"
                    alt="Access Marketing Support"
                    class="w-full h-full object-cover"
                />
            </div>
            <div class="p-6">
                <h3 class="text-xl font-bold mb-2">Access Marketing Support</h3>
                <p class="text-gray-700">Leverage Zomato’s marketing tools and insights to boost your restaurant’s growth and drive customer engagement.</p>
            </div>
        </div>
    </div>

    </main>

    <.live_component module={FooterComponent} id={0}/>

    <.modal id={"login"}>

    <.header class="text-center">
        Log in to Restraurent`s Account
        <:subtitle>
          Don't have an account?
          <.link phx-click={hide_modal("login") |> show_modal("register")} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/restraurents/restraurents/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/restraurents/reset_password"} class="text-sm font-semibold text-brand hover:underline">
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

    <.modal id={"register"}>
        <.header class="text-center">
            Register for an Restraurent Account
            <:subtitle>
                Already registered?
                <.link phx-click={hide_modal("register") |> show_modal("login")} class="font-semibold text-brand hover:underline">
                    Log in
                </.link>
                to your account now.
            </:subtitle>
        </.header>

        <.simple_form
            for={@form}
            id="registration_form"
            phx-submit="save"
            phx-change="validate"
            phx-trigger-action={@trigger_submit}
            action={~p"/restraurents/restraurents/log_in?_action=registered"}
            method="post"
            multipart
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
                <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
            </:actions>
        </.simple_form>
    </.modal>


    """
  end
end
