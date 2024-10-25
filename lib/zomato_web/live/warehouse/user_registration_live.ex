defmodule ZomatoWeb.Warehouse.UserRegistrationLive do
  use ZomatoWeb, :live_view

  alias Zomato.Accounts
  alias Zomato.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="flex justify-center items-center min-h-screen">
  <div class="mx-auto max-w-lg border border-gray-300 shadow-lg p-9 rounded-lg bg-white">
    <.header class="text-center text-2xl font-bold">
      Register for an account
      <:subtitle>
        <p class="text-gray-600 text-sm mt-2">
          Already registered?
          <.link navigate={~p"/warehouse/users/log_in"} class="font-semibold text-brand hover:underline">
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

      <:actions>
        <.button phx-disable-with="Creating account..." class="w-full bg-brand text-white hover:bg-brand-dark">
          Create an account
        </.button>
      </:actions>
    </.simple_form>
  </div>
</div>

    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
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
end
