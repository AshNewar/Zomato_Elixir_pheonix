defmodule Zomato.RabbitMQ do
  use GenServer
  alias Zomato.Orders.OrderNotifier
  alias Zomato.Orders
  alias AMQP.Connection
  alias AMQP.Channel
  alias AMQP.Queue

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @exchange "prod_exchange"
  @queue "prod_queue"

  @impl true
  def init(_) do
    rabbitmq_user = System.get_env("RABBITMQ_USER") || "rabbitmq"
    rabbitmq_pass = System.get_env("RABBITMQ_PASSWORD") || "rabbitmq"
    rabbitmq_host = System.get_env("RABBITMQ_HOST") || "localhost"

    # IO.inpsect("Connecting to RabbitMQ")
    {:ok, conn} = Connection.open(username: rabbitmq_user, password: rabbitmq_pass, host: rabbitmq_host)
    {:ok, chan} = Channel.open(conn)
    IO.inspect("RabbitMQ Connection and Channel opened")

    :ok = AMQP.Exchange.declare(chan, @exchange, :direct)
    {:ok, _} = Queue.declare(chan, @queue)
    :ok = Queue.bind(chan, @queue, @exchange)
    IO.inspect("Queue and Exchange declared")

    AMQP.Basic.consume(chan, @queue)
    IO.inspect("Consumer Ready")

    {:ok, %{conn: conn, chan: chan}}
  end

  def publish(message) do
    IO.inspect("Publishing message:")
    GenServer.cast(__MODULE__, {:publish, message})
  end

  @impl true
  def handle_cast({:publish, message}, %{chan: chan} = state) do
    AMQP.Basic.publish(chan, @exchange, "", message)
    {:noreply, state}
  end

  @impl true
  def handle_info({:basic_deliver, payload, _meta}, state) do
    IO.inspect("Received Orders")

    case Jason.decode(payload) do
      {:ok, message} ->
        cart_id = message["cart_id"]
        user_id = message["user_id"]
        Enum.each(message["group_items"], fn {restaurant_id, items_for_restaurant} ->
          total_amount_for_restaurant =
            Enum.reduce(items_for_restaurant, 0, fn item, acc ->
              acc + (item["price"] * item["quantity"])
            end)
            Orders.create_order(cart_id, user_id, String.to_integer(restaurant_id), total_amount_for_restaurant)

        end)
        Orders.update_order_count_by_cart(cart_id)
        OrderNotifier.order_confirmation(%{id: cart_id, user: %{name: message["name"], email: message["email"]}})

      {:error, _reason} ->
        IO.puts("Failed to decode message")
    end

    IO.inspect("Orders created and Mail Sent" )


    {:noreply, state}
  end

  @impl true
def handle_info({:basic_consume_ok, _consumer_tag}, state) do
  IO.puts("Consumer successfully registered")
  {:noreply, state}
end

  @impl true
def handle_info(message, state) do
  IO.inspect(message, label: "Unexpected message")
  {:noreply, state}
end

  @impl true
  def terminate(_, %{conn: conn}) do
    Connection.close(conn)
  end
end
