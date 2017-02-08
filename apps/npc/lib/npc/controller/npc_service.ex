defmodule Helix.NPC.Controller.NPCService do

  use GenServer

  alias HELF.Broker
  alias Helix.NPC.Controller.NPCQuery

  @type state :: nil

  @spec start_link() :: GenServer.on_start
  def start_link do
    GenServer.start_link(__MODULE__, [], name: :npc_service)
  end

  @doc false
  def handle_broker_call(pid, "npc.create", params, _request) do
    reply = GenServer.call(pid, {:npc, :create, params})
    {:reply, reply}
  end

  @doc false
  def handle_broker_call(pid, "npc.query", msg, _request) do
    %{query: query, params: params} = msg
    response = GenServer.call(pid, {:npc, :query, query, params})
    {:reply, response}
  end

  @spec init(any) :: {:ok, state}
  @doc false
  def init(_args) do
    Broker.subscribe("npc.create", call: &handle_broker_call/4)
    {:ok, nil}
  end

  @spec handle_call({:npc, :create, any}, GenServer.from, state) :: {:noreply, nil}
  @spec handle_call({:npc, :query, any}, GenServer.from, state) ::
    {:reply, {:ok, any} | {:error, any | :notfound | :invalid_query}, state}
  @doc false
  def handle_call({:npc, :create, _struct}, _from, state) do
    {:noreply, state}
  end
  def handle_call({:npc, :query, name, params}, _from, state) do
    response = NPCQuery.handle_query(name, params)

    {:reply, response, state}
  end
end