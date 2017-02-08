defmodule Helix.Log.Controller.LogService do

  use GenServer

  alias HELF.Broker
  alias Helix.Log.Controller.LogQuery

  @type state :: nil

  @spec start_link() :: GenServer.on_start
  def start_link do
    GenServer.start_link(__MODULE__, [], name: :log_service)
  end

  def handle_broker_call(pid, "log.query", msg, _) do
    %{query: query, params: params} = msg
    response = GenServer.call(pid, {:log, :query, query, params})
    {:reply, response}
  end

  @spec init(any) :: {:ok, state}
  @doc false
  def init(_) do
    Broker.subscribe("log.query", call: &handle_broker_call/4)

    {:ok, nil}
  end

  @spec handle_call(
    {:log, :query, String.t, map},
    GenServer.from,
    state) ::
      {:reply, {:ok, any} | {:error, any | :notfound | :invalid_query}, state}
  def handle_call({:log, :query, name, params}, _from, state) do
    response = LogQuery.handle_query(name, params)

    {:reply, response, state}
  end
end