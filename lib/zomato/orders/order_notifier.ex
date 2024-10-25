defmodule Zomato.Orders.OrderNotifier do
  import Swoosh.Email

  alias Zomato.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Zomato", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  def order_confirmation(order) do
    deliver(order.user.email, "Order Confirmation", """

    ==============================

    Hi #{order.user.name},
    Thank you for your order! Yours Order ID is #{order.id}.
    Your order has been confirmed and will be delivered to you soon.

    Hope You enjoy it :)

    From Zomato

    ==============================
    """)
  end
end
