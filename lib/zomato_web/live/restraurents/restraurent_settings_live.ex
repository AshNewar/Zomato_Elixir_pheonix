defmodule ZomatoWeb.Restraurents.RestraurentSettingsLive do
  use ZomatoWeb, :live_view

  alias Zomato.Shops

  def render(assigns) do
    ~H"""
    <div class="flex justify-center items-center min-h-screen bg-gray-100">
    <div class="w-full max-w-lg bg-white shadow-lg rounded-lg p-8 space-y-12 divide-y">

    <.header class="text-center">
      Account Settings
      <:subtitle>Manage your account email address and password settings</:subtitle>
    </.header>

    <div class="space-y-12 divide-y">
      <div>
        <.simple_form
          for={@email_form}
          id="email_form"
          phx-submit="update_email"
          phx-change="validate_email"
        >
          <.input field={@email_form[:email]} type="email" label="Email" required />
          <.input
            field={@email_form[:current_password]}
            name="current_password"
            id="current_password_for_email"
            type="password"
            label="Current password"
            value={@email_form_current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Email</.button>
          </:actions>
        </.simple_form>
      </div>
      <div>
        <.simple_form
          for={@password_form}
          id="password_form"
          action={~p"/restraurents/restraurents/log_in?_action=password_updated"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
        >
          <input
            name={@password_form[:email].name}
            type="hidden"
            id="hidden_restraurent_email"
            value={@current_email}
          />
          <.input field={@password_form[:password]} type="password" label="New password" required />
          <.input
            field={@password_form[:password_confirmation]}
            type="password"
            label="Confirm new password"
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="password"
            label="Current password"
            id="current_password_for_password"
            value={@current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Password</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>

    </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Shops.update_restraurent_email(socket.assigns.current_restraurent, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/restraurents/restraurents/settings")}
  end

  def mount(_params, _session, socket) do
    restraurent = socket.assigns.current_restraurent
    email_changeset = Shops.change_restraurent_email(restraurent)
    password_changeset = Shops.change_restraurent_password(restraurent)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, restraurent.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "restraurent" => restraurent_params} = params

    email_form =
      socket.assigns.current_restraurent
      |> Shops.change_restraurent_email(restraurent_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "restraurent" => restraurent_params} = params
    restraurent = socket.assigns.current_restraurent

    case Shops.apply_restraurent_email(restraurent, password, restraurent_params) do
      {:ok, applied_restraurent} ->
        Shops.deliver_restraurent_update_email_instructions(
          applied_restraurent,
          restraurent.email,
          &url(~p"/restraurents/restraurents/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "restraurent" => restraurent_params} = params

    password_form =
      socket.assigns.current_restraurent
      |> Shops.change_restraurent_password(restraurent_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "restraurent" => restraurent_params} = params
    restraurent = socket.assigns.current_restraurent

    case Shops.update_restraurent_password(restraurent, password, restraurent_params) do
      {:ok, restraurent} ->
        password_form =
          restraurent
          |> Shops.change_restraurent_password(restraurent_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
