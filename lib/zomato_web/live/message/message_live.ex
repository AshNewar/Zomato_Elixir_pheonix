defmodule ZomatoWeb.Warehouse.MessageLive do
  alias Zomato.Accounts
  alias Zomato.Message
  use ZomatoWeb, :live_view

  def mount(%{"room_id" => room_id}, _session, socket) do
    if connected?(socket), do: Message.subscribe()
    form =
      %Message{}
      |> Message.changeset(%{})
      |> to_form(as: "form")
    {:ok,
      socket
      |> stream(:messages, Message.list_messages(room_id) |> Enum.reverse())
      |> assign(:form, form)
      |> assign(:room_id, room_id)
    }
  end

  def render(assigns) do
    ~H"""

    <div class="flex flex-col h-screen bg-gray-100">
    <div class="flex flex-1">

      <aside class="hidden md:flex flex-col w-1/6  bg-red-400 p-4 space-y-4 text-white font-bold">
        <h2 class="text-2xl  text-center ">Chat Rooms</h2>
        <ul class="space-y-2">
          <li><a href={~p"/warehouse/users/chat?room_id=1"} class="block p-2 text-xl bg-red-300 rounded-md hover:bg-red-400 transition">General</a></li>
          <li><a href={~p"/warehouse/users/chat?room_id=2"} class="block p-2 text-xl bg-red-300 rounded-md hover:bg-red-400 transition">Suggestions</a></li>
          <li><a href={~p"/warehouse/users/chat?room_id=3"} class="block p-2 text-xl bg-red-300 rounded-md hover:bg-red-400 transition">Travellers Point</a></li>
          <li><a href={~p"/warehouse/users/chat?room_id=4"} class="block p-2 text-xl bg-red-300 rounded-md hover:bg-red-400 transition">Party</a></li>
        </ul>
      </aside>

    <div class="flex flex-1 flex-col">

      <aside class="md:hidden bg-red-400 p-2 overflow-x-auto">
        <ul  class="flex space-x-4" >
          <li><a href="#" class="block p-2 bg-gray-300 rounded-md hover:bg-gray-400 transition">General</a></li>
          <li><a href="#" class="block p-2 bg-gray-300 rounded-md hover:bg-gray-400 transition">Suggestions</a></li>
          <li><a href="#" class="block p-2 bg-gray-300 rounded-md hover:bg-gray-400 transition">Travellers Point</a></li>
          <li><a href="#" class="block p-2 bg-gray-300 rounded-md hover:bg-gray-400 transition">Party</a></li>
        </ul>
      </aside>

      <header class="flex justify-between items-center bg-red-400 text-white p-4">
        <h1 class="text-xl font-bold">Chatting In Room <%= @room_id %></h1>
        <.link href={~p"/"} >
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" width="15" height="15">
            <path strokeLinecap="round" strokeLinejoin="round" d="m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25" />
          </svg>
        </.link>
      </header>

      <!-- Middle Section: Chat Area -->
      <div class="flex-1 overflow-y-auto p-4 space-y-4 bg-white">
        <ul id="msg-list" phx-update="stream" class="flex-1 space-y-4">

        <%= for {_id, message} <- @streams.messages do %>
        <%= if message.room_id == String.to_integer(@room_id) do %>
            <li id={"msg-#{message.id}"}>
            <%= if message.user_id != @current_user.id do %>
            <div class="flex items-start space-x-2">
              <img src={message.user.profile_pic} alt="Sender" class="w-16 h-16 rounded-full border-2 border-stone-400">
              <div class="bg-gray-200 p-3 rounded-lg max-w-xs overfl20241020121757_create_messagesow-hidden break-words">
                <p class="text-sm font-bold"><%= message.user.name%></p>
                <p><%= message.message%></p>
              </div>
            </div>
            <% else %>
            <div class="flex items-start justify-end space-x-2">
              <div class="bg-red-400 text-white p-3 rounded-lg max-w-xs overflow-hidden break-words">
              <p class="text-sm font-bold"><%= message.user.name%></p>
                <p><%= message.message%></p>
              </div>
              <img src={message.user.profile_pic} alt="Sender" class="w-16 h-16 rounded-full border-2 border-stone-400">
            </div>

            <% end %>

            </li>
        <% end %>


        <% end %>
        </ul>

      </div>


      <form id="form" phx-submit="new_message" phx-change="validate_form" class="flex items-center space-x-2 bg-white p-2 rounded-lg shadow-md">
        <input type="text" name="message" placeholder="Type a message..." required
              class="flex-grow border border-gray-300 rounded-lg p-4 focus:outline-none focus:ring-2 focus:ring-red-500">
        <button type="submit" class="bg-red-400 text-white p-4 rounded-md hover:bg-red-500 transition-all duration-300">
          Send
        </button>
      </form>

    </div>
    </div>
    </div>
    """
  end



  def handle_info({:message_created, message}, socket) do
    message =
      message
      |> Map.put(:user, Accounts.get_user!(message.user_id))


    socket= socket |> stream_insert(:messages, message)
    {:noreply, socket}
  end


  def handle_event("validate_form", %{"message" => message}, socket) do
    form_params = %{"message" => message}
    changeset = Message.changeset(%Message{}, form_params)

    {:noreply, assign(socket, :form, to_form(changeset, as: "form"))}
  end

  def handle_event("new_message", %{"message" => message}, socket) do
    form_params = %{"message" => message}

    form_params = Map.put(form_params, "user_id", socket.assigns.current_user.id)
    form_params = Map.put(form_params, "room_id", socket.assigns.room_id)

    case Message.create_message(form_params) do
      :ok ->
        {:noreply,
          socket
        }

      {:ok, _message} ->
        {:noreply,
          socket
        }

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end




end
