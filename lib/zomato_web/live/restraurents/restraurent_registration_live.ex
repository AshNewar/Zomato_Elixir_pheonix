defmodule ZomatoWeb.Restraurents.RestraurentRegistrationLive do
  use ZomatoWeb, :live_view

  alias Zomato.Shops
  alias Zomato.Shops.Restraurent
  
  def render(assigns) do
    ~H"""

    """
  end

  def mount(_params, _session, socket) do
    changeset = Shops.change_restraurent_registration(%Restraurent{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)
      |> allow_upload(:image, accept: ~w(.png .jpg .jpeg), max_entries: 2)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"restraurent" => restraurent_params}, socket) do
    restraurent_params
    |> Map.put("profile_pic", List.first(consume_files(socket)))

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

  defp consume_files(socket) do
    consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
      dest = Path.join(Application.app_dir(:my_app, "priv/static/uploads"), Path.basename(path))
      # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
      File.cp!(path, dest)

      {:postpone, ~p"/uploads/#{Path.basename(dest)}"}
    end)


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
end
