defmodule Helix.Account.Controller.AccountQueryTest do

  use ExUnit.Case, async: true

  alias HELF.Broker
  alias HELL.TestHelper.Random
  alias Helix.Account.Controller.Account, as: AccountController
  alias Helix.Account.Controller.AccountSetting, as: AccountSettingController
  alias Helix.Account.Model.Setting
  alias Helix.Account.Repo

  defp create_user() do
    username = Random.username()
    email = Burette.Internet.email()
    password = Burette.Internet.password()

    params = %{
      username: username,
      email: email,
      password_confirmation: password,
      password: password
    }

    {:ok, account} = AccountController.create(params)
    account
  end

  def create_setting() do
    setting_id = Random.setting_id()
    default_value = Burette.Color.name()

    %{setting_id: setting_id, default_value: default_value}
    |> Setting.create_changeset()
    |> Repo.insert()

    setting_id
  end

  setup_all do
    setting_id = create_setting()
    {:ok, setting_id: setting_id}
  end

  describe "querying getAccout by account_id" do
    test "returns a map with account information" do
      account = create_user()
      msg = %{query: "getAccount", params: %{id: account.account_id}}

      {_, {:ok, received}} = Broker.call("account.query", msg)

      expected = %{
        account_id: account.account_id,
        username: account.username,
        display_name: account.display_name
      }

      assert expected == received
    end

    test "fails when account doesn't exists" do
      msg = %{query: "getAccount", params: %{id: Random.pk()}}

      {_, result} = Broker.call("account.query", msg)

      assert {:error, :notfound} == result
    end
  end

  describe "querying getAccout by username" do
    test "returns a map with account information" do
      account = create_user()
      msg = %{query: "getAccount", params: %{username: account.username}}

      {_, {:ok, received}} = Broker.call("account.query", msg)

      expected = %{
        account_id: account.account_id,
        username: account.username,
        display_name: account.display_name
      }

      assert expected == received
    end

    test "fails when account doesn't exists" do
      msg = %{query: "getAccount", params: %{username: Random.username()}}

      {_, result} = Broker.call("account.query", msg)

      assert {:error, :notfound} == result
    end
  end

  describe "querying getAccountSettings" do
    test "returns a map with custom values" do
      a = create_user()
      s = Enum.map(0..5, fn _ ->
        id = create_setting()
        custom_val = Random.string(min: 10)

        {id, custom_val}
      end)

      Enum.each(s, fn {k, v} -> AccountSettingController.put(a, k, v) end)

      custom_settings = MapSet.new(s)

      msg = %{
        query: "getAccountSettings",
        params: %{id: a.account_id}
      }

      {_, {:ok, settings}} = Broker.call("account.query", msg)

      fetched =
        settings
        |> Enum.to_list()
        |> MapSet.new()

      assert MapSet.subset?(custom_settings, fetched)
    end

    test "fallbacks to default setting value" do
      a = create_user()
      defaults =
        Setting
        |> Repo.all()
        |> Enum.map(&({&1.setting_id, &1.default_value}))
        |> MapSet.new()

      msg = %{
        query: "getAccountSettings",
        params: %{id: a.account_id}
      }

      {_, {:ok, settings}} = Broker.call("account.query", msg)

      fetched =
        settings
        |> Enum.to_list()
        |> MapSet.new()

      assert MapSet.equal?(defaults, fetched)
    end
  end

  test "querying fails with invalid query" do
    msg = %{query: Random.string(), params: %{}}

    {_, result} = Broker.call("account.query", msg)

    assert {:error, :invalid_query} == result
  end
end