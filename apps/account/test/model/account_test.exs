defmodule Helix.Account.Model.AccountTest do

  use ExUnit.Case, async: true

  require Integer

  alias Comeonin.Bcrypt
  alias Ecto.Changeset
  alias HELL.TestHelper.Random
  alias Helix.Account.Model.Account
  alias Helix.Account.Repo

  defp generate_params() do
    email = Burette.Internet.email()
    passw = Burette.Internet.password()
    %{
      email: email,
      password_confirmation: passw,
      password: passw
    }
  end

  describe "creating account changeset" do
    test "requires fields email, password and password_confirmation" do
      cs = Account.create_changeset(%{})

      assert :email in Keyword.keys(cs.errors)
      assert :password in Keyword.keys(cs.errors)
      assert :password_confirmation in Keyword.keys(cs.errors)
    end

    test "requires a valid email" do
      invalid_email =
        [max: 7]
        |> Random.string()
        |> String.downcase()

      cs = Account.create_changeset(%{email: invalid_email})

      assert :email in Keyword.keys(cs.errors)
    end

    test "requires a unique email" do
      params = generate_params()

      params
      |> Account.create_changeset()
      |> Repo.insert!()

      {:error, cs} =
        params
        |> Account.create_changeset()
        |> Repo.insert()

      assert :email in Keyword.keys(cs.errors)
    end

    test "downcases the email to make it case insensitive" do
      params = generate_params()
      cs = Account.create_changeset(params)
      email = String.downcase(params.email)

      assert email == Changeset.get_field(cs, :email)
    end

    test "hashes the password" do
      params = generate_params()
      cs = Account.create_changeset(params)
      password = Changeset.get_field(cs, :password)

      assert Bcrypt.checkpw(params.password, password)
    end

    test "requires a password with at least 8 characters" do
      params = %{password: Random.string(max: 7)}
      cs = Account.create_changeset(params)

      assert :password in Keyword.keys(cs.errors)
    end

    test "requires that password and password_confirmation are equal" do
      params = generate_params()
      params = %{params | password_confirmation: Burette.Internet.password()}
      cs = Account.create_changeset(params)

      assert :password_confirmation in Keyword.keys(cs.errors)
    end
  end

  describe "updating account changeset" do
    test "requires a valid email" do
      params1 = generate_params()
      params2 = %{params1 | email: Random.string(min: 6)}

      cs1 = Account.create_changeset(params1)
      cs2 = Account.update_changeset(cs1, params2)

      assert :email in Keyword.keys(cs2.errors)
    end

    test "requires a unique email" do
      existing_email =
        generate_params()
        |> Account.create_changeset()
        |> Repo.insert!()
        |> Map.fetch!(:email)

      params1 = generate_params()
      params2 = %{params1 | email: existing_email}

      cs1 =
        params1
        |> Account.create_changeset()
        |> Repo.insert!()

      {:error, cs2} =
        cs1
        |> Account.update_changeset(params2)
        |> Repo.update()

      assert :email in Keyword.keys(cs2.errors)
    end

    test "requires a password with at least 8 characters" do
      params1 = generate_params()
      params2 = %{params1 | password: Random.string(max: 7)}

      cs1 = Account.create_changeset(params1)
      cs2 = Account.update_changeset(cs1, params2)

      assert :password in Keyword.keys(cs2.errors)
    end

    test "requires that password_confirmation is equal to password" do
      params1 = generate_params()
      params2 =
        params1
        |> Map.put(:password, Random.string(min: 8))
        |> Map.put(:password_confirmation, Random.string(min: 8))

      cs1 = Account.create_changeset(params1)
      cs2 = Account.update_changeset(cs1, params2)

      assert :password_confirmation in Keyword.keys(cs2.errors)
    end

    test "replaces email, password and confirmed with params" do
      params1 = generate_params()
      params2 = generate_params()
      params2 = Map.put(params2, :confirmed, true)

      cs1 = Account.create_changeset(params1)
      cs2 = Account.update_changeset(cs1, params2)

      email1 = String.downcase(params1.email)
      email2 = String.downcase(params2.email)

      password1 = Changeset.get_field(cs1, :password)
      password2 = Changeset.get_field(cs2, :password)

      # params1 and cs1 fields are matching
      assert email1 == Changeset.get_field(cs1, :email)
      assert Bcrypt.checkpw(params1.password, password1)

      # params21 and cs2 fields are matching
      assert email2 == Changeset.get_field(cs2, :email)
      assert Bcrypt.checkpw(params2.password, password2)
      assert params2.confirmed == Changeset.get_field(cs2, :confirmed)
    end
  end
end