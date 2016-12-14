defmodule HELM.Server.Controller.ServerService do

  use GenServer

  alias HELF.Broker
  alias HELM.Server.Controller.Server, as: ServerController

  @typep state :: nil

  @spec start_link() :: GenServer.on_start
  def start_link do
    GenServer.start_link(__MODULE__, [], name: :server)
  end

  @spec init(any) :: {:ok, state}
  @doc false
  def init(_) do
    Broker.subscribe("event:entity:created", cast: &handle_broker_cast/4)
    Broker.subscribe("server:create", call: &handle_broker_call/4)
    Broker.subscribe("server:attach", call: &handle_broker_call/4)
    Broker.subscribe("server:detach", call: &handle_broker_call/4)

    {:ok, nil}
  end

  @doc false
  def handle_broker_cast(pid, "event:entity:created", entity_id, request) do
    params = %{
      server_type: "Desktop"}
    GenServer.call(pid, {:server, :created, params, entity_id, request})
  end

  @doc false
  # def handle_broker_call(pid, "server:create", entity_id, _request) do
  #   response = GenServer.call(pid, {:server, :create, entity_id})
  #   {:reply, response}
  # end
  def handle_broker_call(pid, "server:attach", {id, mobo}, _request) do
    response = GenServer.call(pid, {:server, :attach, id, mobo})
    {:reply, response}
  end
  def handle_broker_call(pid, "server:detach", id, _request) do
    response = GenServer.call(pid, {:server, :detach, id})
    {:reply, response}
  end

  # @spec handle_call(
  #   {:server, :create, HELL.PK.t},
  #   GenServer.from,
  #   state) :: {:reply, {:ok, server :: term}
  #             | {:error, reason :: term}, state}
  @spec handle_call(
    {:server, :attach, server :: HELL.PK.t, motherboard :: HELL.PK.t},
    GenServer.from,
    state) :: {:reply, :ok | :error, state}
  @spec handle_call(
    {:server, :detach, HELL.PK.t},
    GenServer.from,
    state) :: {:reply, :ok | :error, state}
  @doc false
  # def handle_call({:server, :create, entity_id}, _from, state) do
  #   return = create_server(entity_id)
  #   {:reply, return, state}
  # end

  @spec handle_call({:server, :create,
    Server.creation_params, PK.t, HeBroker.Request.t},
    GenServer.from,
    state) :: {:reply, {:ok, Server.t} | {:error, Ecto.Changeset.t}, state}
  def handle_call({:server, :create, params, entity_id, req}, _from, state) do
    case ServerController.create(params) do
      {:ok, server} ->
        event_msg = %{
          server_id: server,
          entity_id: entity_id}
        Broker.cast("event:server:created", event_msg, request: req)
        {:reply, {:ok, server}, state}
      error ->
        {:reply, error, state}
    end
  end
  def handle_call({:server, :attach, id, mobo}, _from, state) do
    {status, _} = ServerController.attach(id, mobo)
    {:reply, status, state}
  end
  def handle_call({:server, :detach, id}, _from, state) do
    {status, _} = ServerController.detach(id)
    {:reply, status, state}
  end

  # @spec create_server(entity :: HELL.PK.t) :: {:ok, server :: HELL.PK.t}
  #                                             | {:error, reason :: term}
  # defp create_server(entity_id) do
  #   with {:ok, server} <- CtrlServers.create(%{entity_id: entity_id}) do
  #     Broker.cast("event:server:created", server.server_id)
  #     {:ok, server.server_id}
  #   end
  # end
end