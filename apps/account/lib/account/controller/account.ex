defmodule Helix.Account.Controller.Account do

  alias Comeonin.Bcrypt
  alias Helix.Account.Model.Account
  alias Helix.Account.Repo

  @type find_params :: [
    {:email, Account.email}
    | {:username, Account.username}
  ]

  @spec create(Account.creation_params) ::
    {:ok, Account.t} | {:error, Ecto.Changeset.t}
  def create(params) do
    params
    |> Account.create_changeset()
    |> Repo.insert()
  end

  @spec fetch(Account.id) :: Account.t | nil
  def fetch(account_id),
    do: Repo.get(Account, account_id)

  @spec fetch_by_email(Account.email) :: Account.t | nil
  def fetch_by_email(email),
    do: Repo.get_by(Account, email: email)

  @spec fetch_by_username(Account.username) :: Account.t | nil
  def fetch_by_username(username),
    do: Repo.get_by(Account, username: username)

  @spec update(Account.t, Account.update_params) ::
    {:ok, Account}
    | {:error, Ecto.Changeset.t}
  def update(account, params) do
    account
    |> Account.update_changeset(params)
    |> Repo.update()
  end

  @spec delete(Account.id | Account.t) :: no_return
  def delete(account = %Account{}),
    do: delete(account.account_id)
  def delete(account_id) do
    account_id
    |> Account.Query.by_id()
    |> Repo.delete_all()

    :ok
  end

  @spec login(Account.username, Account.password) ::
    {:ok, Account.t} | {:error, :notfound}
  def login(username, password) do
    case fetch_by_username(username) do
      account = %Account{} ->
        if Bcrypt.checkpw(password, account.password),
          do: {:ok, account},
          else: {:error, :notfound}
      nil ->
        {:error, :notfound}
    end
  end
end