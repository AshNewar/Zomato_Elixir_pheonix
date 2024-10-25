defmodule Zomato.Shops do
  @moduledoc """
  The Shops context.
  """

  import Ecto.Query, warn: false
  alias Zomato.Reviews.Review
  alias Zomato.Orders.Order
  alias Zomato.Repo

  alias Zomato.Shops.{Restraurent, RestraurentToken, RestraurentNotifier}

  # alias Zomato.ImageUploader


  ## Database getters

  @doc """
  Gets a restraurent by email.

  ## Examples

      iex> get_restraurent_by_email("foo@example.com")
      %Restraurent{}

      iex> get_restraurent_by_email("unknown@example.com")
      nil

  """

def search_by_name(query) do
  query_string = "%#{query}%"

  Restraurent
  |> where([r], ilike(r.name, ^query_string))
  |> Repo.all()
end


  def get_restraurent_by_email(email) when is_binary(email) do
    Repo.get_by(Restraurent, email: email)
  end


  def get_best_restaurents do
    query =
      from r in Restraurent,
        join: o in Order,
        on: o.restaurant_id == r.id,
        join: rev in Review,
        on: rev.restaurant_id == r.id,
        group_by: r.id,
        select: %{
          restraurent_id: r.id,
          name: r.name,
          profile_pic: r.profile_pic,
          total_orders: count(o.id),
          avg_rating: avg(rev.rate)
        },
        order_by: [
          desc: count(o.id),
          desc: avg(rev.rate)
        ],
        limit: 4

    Repo.all(query)
  end

  @doc """
  Gets a restraurent by email and password.

  ## Examples

      iex> get_restraurent_by_email_and_password("foo@example.com", "correct_password")
      %Restraurent{}

      iex> get_restraurent_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_restraurent_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    restraurent = Repo.get_by(Restraurent, email: email)
    if Restraurent.valid_password?(restraurent, password), do: restraurent
  end


  def update_restraurent(id,attrs) do
    restraurent = get_restraurent!(id)
      restraurent
      |> Restraurent.update_changeset(attrs)  # Use the update changeset
      |> Repo.update()  # Save changes to the database
  end

  @doc """
  Gets a single restraurent.

  Raises `Ecto.NoResultsError` if the Restraurent does not exist.

  ## Examples

      iex> get_restraurent!(123)
      %Restraurent{}

      iex> get_restraurent!(456)
      ** (Ecto.NoResultsError)

  """
  def get_restraurent!(id), do: Repo.get!(Restraurent, id)

  ## Restraurent registration

  @doc """
  Registers a restraurent.

  ## Examples

      iex> register_restraurent(%{field: value})
      {:ok, %Restraurent{}}

      iex> register_restraurent(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_restraurent(attrs) do

    # Proceed with restaurant registration
    %Restraurent{}
    |> Restraurent.registration_changeset(attrs)
    |> Repo.insert()
  end


  # defp save_upload(%Plug.Upload{path: path}), do: {:ok, path}

  # defp save_upload(_), do: {:error, "Invalid file"}

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking restraurent changes.

  ## Examples

      iex> change_restraurent_registration(restraurent)
      %Ecto.Changeset{data: %Restraurent{}}

  """
  def change_restraurent_registration(%Restraurent{} = restraurent, attrs \\ %{}) do
    Restraurent.registration_changeset(restraurent, attrs, hash_password: false, validate_email: false)
  end

  def change_update_restraurent(%Restraurent{} = restraurent, attrs \\ %{}) do
    Restraurent.update_changeset(restraurent, attrs, hash_password: false, validate_email: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the restraurent email.

  ## Examples

      iex> change_restraurent_email(restraurent)
      %Ecto.Changeset{data: %Restraurent{}}

  """
  def change_restraurent_email(restraurent, attrs \\ %{}) do
    Restraurent.email_changeset(restraurent, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_restraurent_email(restraurent, "valid password", %{email: ...})
      {:ok, %Restraurent{}}

      iex> apply_restraurent_email(restraurent, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_restraurent_email(restraurent, password, attrs) do
    restraurent
    |> Restraurent.email_changeset(attrs)
    |> Restraurent.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the restraurent email using the given token.

  If the token matches, the restraurent email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_restraurent_email(restraurent, token) do
    context = "change:#{restraurent.email}"

    with {:ok, query} <- RestraurentToken.verify_change_email_token_query(token, context),
         %RestraurentToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(restraurent_email_multi(restraurent, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp restraurent_email_multi(restraurent, email, context) do
    changeset =
      restraurent
      |> Restraurent.email_changeset(%{email: email})
      |> Restraurent.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:restraurent, changeset)
    |> Ecto.Multi.delete_all(:tokens, RestraurentToken.by_restraurent_and_contexts_query(restraurent, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given restraurent.

  ## Examples

      iex> deliver_restraurent_update_email_instructions(restraurent, current_email, &url(~p"/restraurents/restraurents/settings/confirm_email/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_restraurent_update_email_instructions(%Restraurent{} = restraurent, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, restraurent_token} = RestraurentToken.build_email_token(restraurent, "change:#{current_email}")

    Repo.insert!(restraurent_token)
    RestraurentNotifier.deliver_update_email_instructions(restraurent, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the restraurent password.

  ## Examples

      iex> change_restraurent_password(restraurent)
      %Ecto.Changeset{data: %Restraurent{}}

  """
  def change_restraurent_password(restraurent, attrs \\ %{}) do
    Restraurent.password_changeset(restraurent, attrs, hash_password: false)
  end

  @doc """
  Updates the restraurent password.

  ## Examples

      iex> update_restraurent_password(restraurent, "valid password", %{password: ...})
      {:ok, %Restraurent{}}

      iex> update_restraurent_password(restraurent, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_restraurent_password(restraurent, password, attrs) do
    changeset =
      restraurent
      |> Restraurent.password_changeset(attrs)
      |> Restraurent.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:restraurent, changeset)
    |> Ecto.Multi.delete_all(:tokens, RestraurentToken.by_restraurent_and_contexts_query(restraurent, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{restraurent: restraurent}} -> {:ok, restraurent}
      {:error, :restraurent, changeset, _} -> {:error, changeset}
    end
  end




  ## Session

  @doc """
  Generates a session token.
  """
  def generate_restraurent_session_token(restraurent) do
    {token, restraurent_token} = RestraurentToken.build_session_token(restraurent)
    Repo.insert!(restraurent_token)
    token
  end

  @doc """
  Gets the restraurent with the given signed token.
  """
  def get_restraurent_by_session_token(token) do
    {:ok, query} = RestraurentToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_restraurent_session_token(token) do
    Repo.delete_all(RestraurentToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given restraurent.

  ## Examples

      iex> deliver_restraurent_confirmation_instructions(restraurent, &url(~p"/restraurents/restraurents/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_restraurent_confirmation_instructions(confirmed_restraurent, &url(~p"/restraurents/restraurents/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_restraurent_confirmation_instructions(%Restraurent{} = restraurent, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if restraurent.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, restraurent_token} = RestraurentToken.build_email_token(restraurent, "confirm")
      Repo.insert!(restraurent_token)
      RestraurentNotifier.deliver_confirmation_instructions(restraurent, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a restraurent by the given token.

  If the token matches, the restraurent account is marked as confirmed
  and the token is deleted.
  """
  def confirm_restraurent(token) do
    with {:ok, query} <- RestraurentToken.verify_email_token_query(token, "confirm"),
         %Restraurent{} = restraurent <- Repo.one(query),
         {:ok, %{restraurent: restraurent}} <- Repo.transaction(confirm_restraurent_multi(restraurent)) do
      {:ok, restraurent}
    else
      _ -> :error
    end
  end

  defp confirm_restraurent_multi(restraurent) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:restraurent, Restraurent.confirm_changeset(restraurent))
    |> Ecto.Multi.delete_all(:tokens, RestraurentToken.by_restraurent_and_contexts_query(restraurent, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given restraurent.

  ## Examples

      iex> deliver_restraurent_reset_password_instructions(restraurent, &url(~p"/restraurents/restraurents/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_restraurent_reset_password_instructions(%Restraurent{} = restraurent, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, restraurent_token} = RestraurentToken.build_email_token(restraurent, "reset_password")
    Repo.insert!(restraurent_token)
    RestraurentNotifier.deliver_reset_password_instructions(restraurent, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the restraurent by reset password token.

  ## Examples

      iex> get_restraurent_by_reset_password_token("validtoken")
      %Restraurent{}

      iex> get_restraurent_by_reset_password_token("invalidtoken")
      nil

  """
  def get_restraurent_by_reset_password_token(token) do
    with {:ok, query} <- RestraurentToken.verify_email_token_query(token, "reset_password"),
         %Restraurent{} = restraurent <- Repo.one(query) do
      restraurent
    else
      _ -> nil
    end
  end

  @doc """
  Resets the restraurent password.

  ## Examples

      iex> reset_restraurent_password(restraurent, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Restraurent{}}

      iex> reset_restraurent_password(restraurent, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_restraurent_password(restraurent, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:restraurent, Restraurent.password_changeset(restraurent, attrs))
    |> Ecto.Multi.delete_all(:tokens, RestraurentToken.by_restraurent_and_contexts_query(restraurent, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{restraurent: restraurent}} -> {:ok, restraurent}
      {:error, :restraurent, changeset, _} -> {:error, changeset}
    end
  end
end
