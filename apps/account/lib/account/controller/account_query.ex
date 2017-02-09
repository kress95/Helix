defmodule Helix.Account.Controller.AccountQuery do

  alias Helix.Account.Controller.AccountSetting, as: AccountSettingController
  alias Helix.Account.Model.Account
  alias Helix.Account.Repo

  def handle_query("getAccount", %{id: account_id}) do
    # FIXME: add changeset validations T420
    account_id
    |> Account.Query.by_id()
    |> Repo.one()
    |> format_get_account()
  end

  def handle_query("getAccount", %{username: username}) do
    # FIXME: add changeset validations T420
    username
    |> String.downcase()
    |> Account.Query.by_username()
    |> Repo.one()
    |> format_get_account()
  end

  def handle_query("getAccountSettings", %{id: account_id}) do
    msg = AccountSettingController.get_settings(account_id)
    {:ok, msg}
  end

  def handle_query(_, _),
    do: {:error, :invalid_query}

  # FIXME: add username/display_name once D59 lands
  defp format_get_account(account = %Account{}) do
    msg = %{
      account_id: account.account_id,
      username: account.username,
      display_name: account.display_name
    }

    {:ok, msg}
  end
  defp format_get_account(nil),
    do: {:error, :notfound}
end