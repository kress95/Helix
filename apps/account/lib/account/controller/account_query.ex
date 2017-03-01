defmodule Helix.Account.Controller.AccountQuery do

  alias Helix.Account.Controller.AccountService

  def handle_query("getAccount", %{id: account_id}) do
    # FIXME: add changeset validations T420
    account_id
    |> AccountService.find_account()
    |> format_get_account()
  end

  def handle_query("getAccount", %{username: username}) do
    # FIXME: add changeset validations T420
    [username: username]
    |> AccountService.find_account_by()
    |> format_get_account()
  end

  def handle_query("getAccountSettings", %{id: account_id}) do
    msg = AccountService.get_account_settings(account_id)
    {:ok, msg}
  end

  def handle_query(_, _),
    do: {:error, :invalid_query}

  defp format_get_account({:ok, account}) do
    msg = %{
      account_id: account.account_id,
      username: account.username,
      display_name: account.display_name
    }

    {:ok, msg}
  end
  defp format_get_account(error),
    do: error
end