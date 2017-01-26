defmodule Helix.Account.Controller.AccountService do

  use GenServer

  alias HELF.Broker
  alias HELF.Router
  alias Helix.Account.Controller.Account, as: AccountController
  alias Helix.Account.Controller.Session, as: SessionController
  alias Helix.Account.Model.Account

  @typep state :: nil

  @spec start_link() :: GenServer.on_start
  def start_link do
    Router.register("account.create", "account:create")
    Router.register("account.login", "account:login")

    GenServer.start_link(__MODULE__, [], name: :account_service)
  end

  @spec init(any) :: {:ok, state}
  def init(_args) do
    Broker.subscribe("account:create", call: &handle_broker_call/4)
    Broker.subscribe("account:login", call: &handle_broker_call/4)

    {:ok, nil}
  end

  @doc false
  def handle_broker_call(pid, "account:create", params, request) do
    response = GenServer.call(pid, {:account, :create, params, request})
    {:reply, response}
  end
  def handle_broker_call(pid, "account:login", %{email: email, password: password}, _request) do
    response = GenServer.call(pid, {:account, :login, email, password})
    {:reply, response}
  end

  @spec handle_call(
    {:account, :create, Account.creation_params, HeBroker.Request.t},
    GenServer.from,
    state) :: {:reply, {:ok, Account.t} | {:error, Ecto.Changeset.t}, state}
  @spec handle_call(
    {:account, :login, Account.email, Account.password},
    GenServer.from,
    state) :: {:reply, {:ok, Account.id} | {:error, :notfound}, state}
  @doc false
<<<<<<< HEAD
  def handle_call({:account, :create, params, req}, _from, state) do
    with \
      changeset = %{valid?: true} <- Account.create_changeset(params),
      params = %{entity_type: "account"},
      {_, {:ok, entity}} <- Broker.call("entity:create", params, request: req),
      changeset = %{valid?: true} <- Account.put_primary_key(changeset, entity.entity_id),
      {:ok, account} <- AccountController.create(changeset)
    do
      msg = %{account_id: account.account_id}
      Broker.cast("event:account:created", msg, request: req)
      {:reply, {:ok, account}, state}
    else
=======
  def handle_call({:account, :create, params, request}, _from, state) do
    case AccountController.create(params) do
      {:ok, account} ->
        msg = %{account_id: account.account_id}
        Broker.cast("event:account:created", msg, request: request)
        {:reply, {:ok, account}, state}
>>>>>>> Update Account and Entity to use EntityAccount, also fix some invalid typespecs from EntityService.
      {:error, error} ->
        {:reply, {:error, error}, state}
    end
  end
  def handle_call({:account, :login, email, password}, _from, state) do
    with \
      {:ok, account_id} <- AccountController.login(email, password),
      {:ok, token} <- SessionController.create(account_id)
    do
      {:reply, {:ok, token}, state}
    else
      error ->
        {:reply, error, state}
    end
  end
end