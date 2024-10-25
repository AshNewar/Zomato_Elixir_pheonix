defmodule Zomato.ShopsTest do
  use Zomato.DataCase

  alias Zomato.Shops

  import Zomato.ShopsFixtures
  alias Zomato.Shops.{Restraurent, RestraurentToken}

  describe "get_restraurent_by_email/1" do
    test "does not return the restraurent if the email does not exist" do
      refute Shops.get_restraurent_by_email("unknown@example.com")
    end

    test "returns the restraurent if the email exists" do
      %{id: id} = restraurent = restraurent_fixture()
      assert %Restraurent{id: ^id} = Shops.get_restraurent_by_email(restraurent.email)
    end
  end

  describe "get_restraurent_by_email_and_password/2" do
    test "does not return the restraurent if the email does not exist" do
      refute Shops.get_restraurent_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the restraurent if the password is not valid" do
      restraurent = restraurent_fixture()
      refute Shops.get_restraurent_by_email_and_password(restraurent.email, "invalid")
    end

    test "returns the restraurent if the email and password are valid" do
      %{id: id} = restraurent = restraurent_fixture()

      assert %Restraurent{id: ^id} =
               Shops.get_restraurent_by_email_and_password(restraurent.email, valid_restraurent_password())
    end
  end

  describe "get_restraurent!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Shops.get_restraurent!(-1)
      end
    end

    test "returns the restraurent with the given id" do
      %{id: id} = restraurent = restraurent_fixture()
      assert %Restraurent{id: ^id} = Shops.get_restraurent!(restraurent.id)
    end
  end

  describe "register_restraurent/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Shops.register_restraurent(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Shops.register_restraurent(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Shops.register_restraurent(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = restraurent_fixture()
      {:error, changeset} = Shops.register_restraurent(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Shops.register_restraurent(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers restraurents with a hashed password" do
      email = unique_restraurent_email()
      {:ok, restraurent} = Shops.register_restraurent(valid_restraurent_attributes(email: email))
      assert restraurent.email == email
      assert is_binary(restraurent.hashed_password)
      assert is_nil(restraurent.confirmed_at)
      assert is_nil(restraurent.password)
    end
  end

  describe "change_restraurent_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Shops.change_restraurent_registration(%Restraurent{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = unique_restraurent_email()
      password = valid_restraurent_password()

      changeset =
        Shops.change_restraurent_registration(
          %Restraurent{},
          valid_restraurent_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_restraurent_email/2" do
    test "returns a restraurent changeset" do
      assert %Ecto.Changeset{} = changeset = Shops.change_restraurent_email(%Restraurent{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_restraurent_email/3" do
    setup do
      %{restraurent: restraurent_fixture()}
    end

    test "requires email to change", %{restraurent: restraurent} do
      {:error, changeset} = Shops.apply_restraurent_email(restraurent, valid_restraurent_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{restraurent: restraurent} do
      {:error, changeset} =
        Shops.apply_restraurent_email(restraurent, valid_restraurent_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{restraurent: restraurent} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Shops.apply_restraurent_email(restraurent, valid_restraurent_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{restraurent: restraurent} do
      %{email: email} = restraurent_fixture()
      password = valid_restraurent_password()

      {:error, changeset} = Shops.apply_restraurent_email(restraurent, password, %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{restraurent: restraurent} do
      {:error, changeset} =
        Shops.apply_restraurent_email(restraurent, "invalid", %{email: unique_restraurent_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{restraurent: restraurent} do
      email = unique_restraurent_email()
      {:ok, restraurent} = Shops.apply_restraurent_email(restraurent, valid_restraurent_password(), %{email: email})
      assert restraurent.email == email
      assert Shops.get_restraurent!(restraurent.id).email != email
    end
  end

  describe "deliver_restraurent_update_email_instructions/3" do
    setup do
      %{restraurent: restraurent_fixture()}
    end

    test "sends token through notification", %{restraurent: restraurent} do
      token =
        extract_restraurent_token(fn url ->
          Shops.deliver_restraurent_update_email_instructions(restraurent, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert restraurent_token = Repo.get_by(RestraurentToken, token: :crypto.hash(:sha256, token))
      assert restraurent_token.restraurent_id == restraurent.id
      assert restraurent_token.sent_to == restraurent.email
      assert restraurent_token.context == "change:current@example.com"
    end
  end

  describe "update_restraurent_email/2" do
    setup do
      restraurent = restraurent_fixture()
      email = unique_restraurent_email()

      token =
        extract_restraurent_token(fn url ->
          Shops.deliver_restraurent_update_email_instructions(%{restraurent | email: email}, restraurent.email, url)
        end)

      %{restraurent: restraurent, token: token, email: email}
    end

    test "updates the email with a valid token", %{restraurent: restraurent, token: token, email: email} do
      assert Shops.update_restraurent_email(restraurent, token) == :ok
      changed_restraurent = Repo.get!(Restraurent, restraurent.id)
      assert changed_restraurent.email != restraurent.email
      assert changed_restraurent.email == email
      assert changed_restraurent.confirmed_at
      assert changed_restraurent.confirmed_at != restraurent.confirmed_at
      refute Repo.get_by(RestraurentToken, restraurent_id: restraurent.id)
    end

    test "does not update email with invalid token", %{restraurent: restraurent} do
      assert Shops.update_restraurent_email(restraurent, "oops") == :error
      assert Repo.get!(Restraurent, restraurent.id).email == restraurent.email
      assert Repo.get_by(RestraurentToken, restraurent_id: restraurent.id)
    end

    test "does not update email if restraurent email changed", %{restraurent: restraurent, token: token} do
      assert Shops.update_restraurent_email(%{restraurent | email: "current@example.com"}, token) == :error
      assert Repo.get!(Restraurent, restraurent.id).email == restraurent.email
      assert Repo.get_by(RestraurentToken, restraurent_id: restraurent.id)
    end

    test "does not update email if token expired", %{restraurent: restraurent, token: token} do
      {1, nil} = Repo.update_all(RestraurentToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Shops.update_restraurent_email(restraurent, token) == :error
      assert Repo.get!(Restraurent, restraurent.id).email == restraurent.email
      assert Repo.get_by(RestraurentToken, restraurent_id: restraurent.id)
    end
  end

  describe "change_restraurent_password/2" do
    test "returns a restraurent changeset" do
      assert %Ecto.Changeset{} = changeset = Shops.change_restraurent_password(%Restraurent{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Shops.change_restraurent_password(%Restraurent{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_restraurent_password/3" do
    setup do
      %{restraurent: restraurent_fixture()}
    end

    test "validates password", %{restraurent: restraurent} do
      {:error, changeset} =
        Shops.update_restraurent_password(restraurent, valid_restraurent_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{restraurent: restraurent} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Shops.update_restraurent_password(restraurent, valid_restraurent_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{restraurent: restraurent} do
      {:error, changeset} =
        Shops.update_restraurent_password(restraurent, "invalid", %{password: valid_restraurent_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{restraurent: restraurent} do
      {:ok, restraurent} =
        Shops.update_restraurent_password(restraurent, valid_restraurent_password(), %{
          password: "new valid password"
        })

      assert is_nil(restraurent.password)
      assert Shops.get_restraurent_by_email_and_password(restraurent.email, "new valid password")
    end

    test "deletes all tokens for the given restraurent", %{restraurent: restraurent} do
      _ = Shops.generate_restraurent_session_token(restraurent)

      {:ok, _} =
        Shops.update_restraurent_password(restraurent, valid_restraurent_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(RestraurentToken, restraurent_id: restraurent.id)
    end
  end

  describe "generate_restraurent_session_token/1" do
    setup do
      %{restraurent: restraurent_fixture()}
    end

    test "generates a token", %{restraurent: restraurent} do
      token = Shops.generate_restraurent_session_token(restraurent)
      assert restraurent_token = Repo.get_by(RestraurentToken, token: token)
      assert restraurent_token.context == "session"

      # Creating the same token for another restraurent should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%RestraurentToken{
          token: restraurent_token.token,
          restraurent_id: restraurent_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_restraurent_by_session_token/1" do
    setup do
      restraurent = restraurent_fixture()
      token = Shops.generate_restraurent_session_token(restraurent)
      %{restraurent: restraurent, token: token}
    end

    test "returns restraurent by token", %{restraurent: restraurent, token: token} do
      assert session_restraurent = Shops.get_restraurent_by_session_token(token)
      assert session_restraurent.id == restraurent.id
    end

    test "does not return restraurent for invalid token" do
      refute Shops.get_restraurent_by_session_token("oops")
    end

    test "does not return restraurent for expired token", %{token: token} do
      {1, nil} = Repo.update_all(RestraurentToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Shops.get_restraurent_by_session_token(token)
    end
  end

  describe "delete_restraurent_session_token/1" do
    test "deletes the token" do
      restraurent = restraurent_fixture()
      token = Shops.generate_restraurent_session_token(restraurent)
      assert Shops.delete_restraurent_session_token(token) == :ok
      refute Shops.get_restraurent_by_session_token(token)
    end
  end

  describe "deliver_restraurent_confirmation_instructions/2" do
    setup do
      %{restraurent: restraurent_fixture()}
    end

    test "sends token through notification", %{restraurent: restraurent} do
      token =
        extract_restraurent_token(fn url ->
          Shops.deliver_restraurent_confirmation_instructions(restraurent, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert restraurent_token = Repo.get_by(RestraurentToken, token: :crypto.hash(:sha256, token))
      assert restraurent_token.restraurent_id == restraurent.id
      assert restraurent_token.sent_to == restraurent.email
      assert restraurent_token.context == "confirm"
    end
  end

  describe "confirm_restraurent/1" do
    setup do
      restraurent = restraurent_fixture()

      token =
        extract_restraurent_token(fn url ->
          Shops.deliver_restraurent_confirmation_instructions(restraurent, url)
        end)

      %{restraurent: restraurent, token: token}
    end

    test "confirms the email with a valid token", %{restraurent: restraurent, token: token} do
      assert {:ok, confirmed_restraurent} = Shops.confirm_restraurent(token)
      assert confirmed_restraurent.confirmed_at
      assert confirmed_restraurent.confirmed_at != restraurent.confirmed_at
      assert Repo.get!(Restraurent, restraurent.id).confirmed_at
      refute Repo.get_by(RestraurentToken, restraurent_id: restraurent.id)
    end

    test "does not confirm with invalid token", %{restraurent: restraurent} do
      assert Shops.confirm_restraurent("oops") == :error
      refute Repo.get!(Restraurent, restraurent.id).confirmed_at
      assert Repo.get_by(RestraurentToken, restraurent_id: restraurent.id)
    end

    test "does not confirm email if token expired", %{restraurent: restraurent, token: token} do
      {1, nil} = Repo.update_all(RestraurentToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Shops.confirm_restraurent(token) == :error
      refute Repo.get!(Restraurent, restraurent.id).confirmed_at
      assert Repo.get_by(RestraurentToken, restraurent_id: restraurent.id)
    end
  end

  describe "deliver_restraurent_reset_password_instructions/2" do
    setup do
      %{restraurent: restraurent_fixture()}
    end

    test "sends token through notification", %{restraurent: restraurent} do
      token =
        extract_restraurent_token(fn url ->
          Shops.deliver_restraurent_reset_password_instructions(restraurent, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert restraurent_token = Repo.get_by(RestraurentToken, token: :crypto.hash(:sha256, token))
      assert restraurent_token.restraurent_id == restraurent.id
      assert restraurent_token.sent_to == restraurent.email
      assert restraurent_token.context == "reset_password"
    end
  end

  describe "get_restraurent_by_reset_password_token/1" do
    setup do
      restraurent = restraurent_fixture()

      token =
        extract_restraurent_token(fn url ->
          Shops.deliver_restraurent_reset_password_instructions(restraurent, url)
        end)

      %{restraurent: restraurent, token: token}
    end

    test "returns the restraurent with valid token", %{restraurent: %{id: id}, token: token} do
      assert %Restraurent{id: ^id} = Shops.get_restraurent_by_reset_password_token(token)
      assert Repo.get_by(RestraurentToken, restraurent_id: id)
    end

    test "does not return the restraurent with invalid token", %{restraurent: restraurent} do
      refute Shops.get_restraurent_by_reset_password_token("oops")
      assert Repo.get_by(RestraurentToken, restraurent_id: restraurent.id)
    end

    test "does not return the restraurent if token expired", %{restraurent: restraurent, token: token} do
      {1, nil} = Repo.update_all(RestraurentToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Shops.get_restraurent_by_reset_password_token(token)
      assert Repo.get_by(RestraurentToken, restraurent_id: restraurent.id)
    end
  end

  describe "reset_restraurent_password/2" do
    setup do
      %{restraurent: restraurent_fixture()}
    end

    test "validates password", %{restraurent: restraurent} do
      {:error, changeset} =
        Shops.reset_restraurent_password(restraurent, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{restraurent: restraurent} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Shops.reset_restraurent_password(restraurent, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{restraurent: restraurent} do
      {:ok, updated_restraurent} = Shops.reset_restraurent_password(restraurent, %{password: "new valid password"})
      assert is_nil(updated_restraurent.password)
      assert Shops.get_restraurent_by_email_and_password(restraurent.email, "new valid password")
    end

    test "deletes all tokens for the given restraurent", %{restraurent: restraurent} do
      _ = Shops.generate_restraurent_session_token(restraurent)
      {:ok, _} = Shops.reset_restraurent_password(restraurent, %{password: "new valid password"})
      refute Repo.get_by(RestraurentToken, restraurent_id: restraurent.id)
    end
  end

  describe "inspect/2 for the Restraurent module" do
    test "does not include password" do
      refute inspect(%Restraurent{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
