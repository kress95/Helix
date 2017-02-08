defmodule Helix.Account.Controller.AccountQuery do

  alias Helix.Account.Model.Account
  alias Helix.Account.Repo

  def handle_query("getEmail", %{account_id: id}) do
    # FIXME: add changeset validations T420
    result =
      id
      |> Account.Query.by_id()
      |> Account.Query.select_email()
      |> Repo.one()

    case result do
      nil ->
        {:error, :notfound}
      email ->
        {:ok, email}
    end
  end

  def handle_query("getUsername", %{account_id: id}) do
    # FIXME: add changeset validations T420
    # FIXME: change this to fetch username once D59 lands
    result =
      id
      |> Account.Query.by_id()
      |> Account.Query.select_username()
      |> Repo.one()

    case result do
      nil ->
        {:error, :notfound}
      email ->
        {:ok, email}
    end
  end

  def handle_query(_, _),
    do: {:error, :invalid_query}
end