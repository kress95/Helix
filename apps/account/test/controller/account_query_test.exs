defmodule Helix.Account.Controller.AccountQueryTest do

  use ExUnit.Case, async: true

  alias HELF.Broker
  alias HELL.TestHelper.Random
  alias Helix.Account.Controller.Account, as: AccountController

  defp create_user() do
    email = Burette.Internet.email()
    password = Burette.Internet.password()

    params = %{
      username: Random.username(),
      email: email,
      password_confirmation: password,
      password: password
    }

    {:ok, account} = AccountController.create(params)
    account
  end

  describe "querying getUsername" do
    test "succeeds when account exists" do
      account = create_user()
      msg = %{query: "getUsername", params: %{id: account.account_id}}

      {_, {:ok, username}} = Broker.call("account.query", msg)

      assert account.username == username
    end

    test "fails when account doesn't exists" do
      msg = %{query: "getUsername", params: %{id: Random.pk()}}

      {_, result} = Broker.call("account.query", msg)

      assert {:error, :notfound} == result
    end
  end

  test "querying fails with invalid query" do
    msg = %{query: Random.string(), params: %{}}

    {_, result} = Broker.call("account.query", msg)

    assert {:error, :invalid_query} == result
  end
end