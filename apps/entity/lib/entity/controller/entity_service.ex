defmodule Helix.Controller.EntityService do

  use GenServer

  alias HELF.Broker
  alias HELL.PK
  alias Helix.Entity.Controller.Entity, as: EntityController
  alias Helix.Entity.Controller.EntityAccount, as: EntityAccountController
  alias Helix.Entity.Controller.EntityComponent, as: EntityComponentController
  alias Helix.Entity.Controller.EntityServer, as: EntityServerController
  alias Helix.Entity.Model.Entity
  alias Helix.Entity.Repo

  @typep state :: nil

  @spec start_link() :: GenServer.on_start
  def start_link do
    GenServer.start_link(__MODULE__, [], name: :entity_service)
  end

  @spec init(any) :: {:ok, state}
  @doc false
  def init(_args) do
    Broker.subscribe("entity:create", call: &handle_broker_call/4)
    Broker.subscribe("entity:find", call: &handle_broker_call/4)
    Broker.subscribe("event:account:created", cast: &handle_broker_cast/4)
    Broker.subscribe("event:server:created", cast: &handle_broker_cast/4)
    Broker.subscribe("event:component:created", cast: &handle_broker_cast/4)
    {:ok, nil}
  end

  @doc false
  def handle_broker_call(pid, "entity:find", msg, _req) do
    %{entity_id: entity_id} = msg
    response = GenServer.call(pid, {:entity, :find, entity_id})
    {:reply, response}
  end
  def handle_broker_call(pid, "entity:create", params, req) do
    response = GenServer.call(pid, {:entity, :create, params, req})
    {:reply, response}
  end

  @doc false
  def handle_broker_cast(pid, "event:account:created", msg, _req) do
    %{account_id: account_id} = msg
    GenServer.cast(pid, {:account, :created, account_id})
  end

  @doc false
  def handle_broker_cast(pid, "event:server:created", msg, _req) do
    %{
      server_id: server_id,
      entity_id: entity_id} = msg

    GenServer.cast(pid, {:server, :created, server_id, entity_id})
  end

  def handle_broker_cast(pid, "event:component:created", msg, _req) do
    %{
      entity_id: entity_id,
      component_id: component_id} = msg

    GenServer.cast(pid, {:entity, :component, :add, entity_id, component_id})
  end

  @spec handle_call(
    {:entity, :create, Entity.creation_params, HeBroker.Request.t},
    GenServer.from,
    state) :: {:reply, {:ok, Entity.t} | {:error, Ecto.Changeset.t}, state}
  @spec handle_call(
    {:entity, :find, PK.t},
    GenServer.from,
    state) :: {:reply, {:ok, Entity.t} | {:error, :notfound}, state}
  @doc false
  def handle_call({:entity, :create, params, request}, _from, state) do
    case EntityController.create(params) do
      {:ok, entity} ->
        msg = %{entity_id: entity.entity_id}
        Broker.cast("event:entity:created", msg, request: request)
        {:reply, {:ok, entity}, state}
      error ->
        {:reply, error, state}
    end
  end
  def handle_call({:entity, :find, id}, _from, state) do
    response = EntityController.find(id)
    {:reply, response, state}
  end

  @spec handle_cast(
    {:account, :created, PK.t},
    state) :: {:noreply, state}
  @spec handle_cast(
    {:server, :created, PK.t, PK.t},
    state) :: {:noreply, state}
  @spec handle_cast(
    {:entity, :component, :add, Entity.id, PK.t},
    state) :: {:noreply, state}
  def handle_cast({:account, :created, account_id}, state) do
    result = Repo.transaction(fn ->
      with \
        {:ok, entity} <- EntityController.create(%{entity_type: "account"}),
        {:ok, _} <- EntityAccountController.create(entity, account_id)
      do
        entity
      else
        _ ->
          Repo.rollback(:internal)
      end
    end)
    case result do
      {:ok, entity} ->
        msg = %{
          entity_id: entity.entity_id,
          entity_type: entity.entity_type
        }
        Broker.cast("event:entity:created", msg)
        {:noreply, state}
      {:error, _} ->
        {:noreply, state}
    end
  end
  def handle_cast({:server, :created, server_id, entity_id}, state) do
    EntityServerController.create(entity_id, server_id)
    {:noreply, state}
  end
  def handle_cast({:entity, :component, :add, entity_id, comp_id}, state) do
    EntityComponentController.create(entity_id, comp_id)
    {:noreply, state}
  end
end