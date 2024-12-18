defmodule Zomato.Shops.RestraurentNotifier do
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

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(restraurent, url) do
    deliver(restraurent.email, "Confirmation instructions", """

    ==============================

    Hi #{restraurent.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a restraurent password.
  """
  def deliver_reset_password_instructions(restraurent, url) do
    deliver(restraurent.email, "Reset password instructions", """

    ==============================

    Hi #{restraurent.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a restraurent email.
  """
  def deliver_update_email_instructions(restraurent, url) do
    deliver(restraurent.email, "Update email instructions", """

    ==============================

    Hi #{restraurent.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
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
