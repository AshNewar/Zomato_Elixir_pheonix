defmodule ZomatoWeb.Restraurents.RestraurentLoginLive do
  use ZomatoWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex justify-center items-center min-h-screen ">
    <div class=" mx-auto max-w-lg border border-gray-300 shadow-lg p-9 rounded-lg bg-white">
      <.header class="text-center">
        Log in to Restraurent`s Account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/restraurents/register"} class="font-semibold text-brand hover:underline">
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
          <.link href={~p"/restraurents/restraurents/reset_password"} class="text-sm font-semibold text-brand hover:underline">
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
    form = to_form(%{"email" => email}, as: "restraurent")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
