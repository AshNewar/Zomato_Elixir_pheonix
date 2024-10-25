defmodule ZomatoWeb.Warehouse.UserLoginLive do
  use ZomatoWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex justify-center items-center min-h-screen ">
    <div class="mx-auto max-w-lg border border-gray-300 shadow-lg p-9 rounded-lg bg-white">
      <.header class="text-center text-2xl font-bold">
        Log in to your account
        <:subtitle>
          <p class="text-gray-600 text-sm mt-2">
            Don't have an account?
            <.link navigate={~p"/warehouse/users/register"} class="font-semibold text-brand hover:underline">
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
    </div>
    </div>

    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
