defmodule Helix.Entity.Controller.EntityService do

  use GenServer

  alias HELF.Broker
  alias HELL.PK
  alias Helix.Entity.Controller.Entity, as: EntityController
  alias Helix.Entity.Controller.EntityComponent, as: EntityComponentController
  alias Helix.Entity.Controller.EntityQuery
  alias Helix.Entity.Controller.EntityServer, as: EntityServerController
  alias Helix.Entity.Model.Entity

  @typep state :: nil

  @spec start_link() :: GenServer.on_start
  def start_link do
    GenServer.start_link(__MODULE__, [], name: :entity_service)
  end

  @doc false
  def handle_broker_call(pid, "entity.find", msg, _req) do
    %{entity_id: entity_id} = msg
    response = GenServer.call(pid, {:entity, :find, entity_id})
    {:reply, response}
  end
  def handle_broker_call(pid, "entity.query", msg, _req) do
    %{query: query, params: params} = msg

    response = GenServer.call(pid, {:entity, :query, query, params})

    {:reply, response}
  end
  def handle_broker_call(pid, "entity.component.find", msg, _req) do
    %{entity_id: entity_id} = msg

    response = GenServer.call(pid, {:entity, :component, :find, entity_id})

    {:reply, response}
  end
  def handle_broker_call(pid, "entity.server.find", msg, _req) do
    %{entity_id: entity_id} = msg

    response = GenServer.call(pid, {:entity, :server, :find, entity_id})

    {:reply, response}
  end

  @doc false
  def handle_broker_cast(pid, "event.account.created", msg, _) do
    %{account_id: entity_id} = msg
    GenServer.cast(pid, {:entity, :create, entity_id, "account"})
  end
  def handle_broker_cast(pid, "event.server.created", msg, _) do
    %{server_id: server_id, entity_id: entity_id} = msg
    GenServer.cast(pid, {:entity, :server, :add, entity_id, server_id})
  end
  def handle_broker_cast(pid, "event.component.created", msg, _) do
    %{entity_id: entity_id, component_id: component_id} = msg
    GenServer.cast(pid, {:entity, :component, :add, entity_id, component_id})
  end

  @spec init(any) :: {:ok, state}
  @doc false
  def init(_args) do
    Broker.subscribe("entity.find", call: &handle_broker_call/4)
    Broker.subscribe("entity.query", call: &handle_broker_call/4)
    Broker.subscribe("entity.component.find", call: &handle_broker_call/4)
    Broker.subscribe("entity.server.find", call: &handle_broker_call/4)
    Broker.subscribe("event.account.created", cast: &handle_broker_cast/4)
    Broker.subscribe("event.server.created", cast: &handle_broker_cast/4)
    Broker.subscribe("event.component.created", cast: &handle_broker_cast/4)

    {:ok, nil}
  end

  @spec handle_call(
    {:entity, :find, PK.t},
    GenServer.from,
    state) :: {:reply, {:ok, Entity.t} | {:error, :notfound}, state}
  @spec handle_call(
    {:entity, :component, :find, PK.t},
    GenServer.from,
    state) :: {:reply, {:ok, [PK.t]}, state}
  @spec handle_call(
    {:entity, :server, :find, PK.t},
    GenServer.from,
    state) :: {:reply, {:ok, [PK.t]}, state}
  @spec handle_call(
    {:entity, :query, String.t, map},
    GenServer.from,
    state) :: {:reply, {:ok, any} | {:error, :notfound | :invalid_query}, state}
  @doc false
  def handle_call({:entity, :find, id}, _from, state) do
    response = find_entity(id)
    {:reply, response, state}
  end
  def handle_call({:entity, :component, :find, id}, _from, state) do
    component_list = EntityComponentController.find(id)
    {:reply, {:ok, component_list}, state}
  end
  def handle_call({:entity, :server, :find, id}, _from, state) do
    server_list = EntityServerController.find(id)
    {:reply, {:ok, server_list}, state}
  end
  def handle_call({:entity, :query, name, params}, _from, state) do
    response = EntityQuery.handle_query(name, params)

    {:reply, response, state}
  end

  @spec handle_cast({:entity, :create, PK.t, String.t}, state) ::
    {:noreply, state}
  @spec handle_cast({:entity, :server, :add, PK.t, PK.t}, state) ::
    {:noreply, state}
  @spec handle_cast({:entity, :component, :add, PK.t, PK.t}, state) ::
    {:noreply, state}
  def handle_cast({:entity, :create, id, entity_type}, state) do
    params = %{
      entity_id: id,
      entity_type: entity_type
    }

    with {:ok, entity} <- EntityController.create(params) do
      Broker.cast("event.entity.created", %{entity_id: entity.entity_id})
    end

    {:noreply, state}
  end
  def handle_cast({:entity, :server, :add, id, server_id}, state) do
    EntityServerController.create(id, server_id)
    {:noreply, state}
  end
  def handle_cast({:entity, :component, :add, id, component_id}, state) do
    EntityComponentController.create(id, component_id)
    {:noreply, state}
  end

  @spec list_components(PK.t) :: {:ok, Entity.t} | {:error, :notfound}
  def list_components(entity_id),
    do: EntityComponentController.find(entity_id)
  @spec find_entity(PK.t) :: {:ok, Entity.t} | {:error, :notfound}
  def find_entity(entity_id),
    do: EntityController.find(entity_id)
end