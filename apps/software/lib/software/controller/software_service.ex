defmodule Helix.Software.Controller.SoftwareService do

  use GenServer

  alias HELF.Broker
  alias Helix.Software.Controller.SoftwareQuery

  @type state :: nil

  @spec start_link() :: GenServer.on_start
  def start_link do
    GenServer.start_link(__MODULE__, [], name: :software)
  end

  def handle_broker_call(pid, "software.query", msg, _) do
    %{query: query, params: params} = msg
    response = GenServer.call(pid, {:software, :query, query, params})
    {:reply, response}
  end

  @spec init(any) :: {:ok, state}
  @doc false
  def init(_) do
    Broker.subscribe("software.query", call: &handle_broker_call/4)

    {:ok, nil}
  end

  @spec handle_call(
    {:software, :query, String.t, map},
    GenServer.from,
    state) ::
      {:reply, {:ok, any} | {:error, any | :notfound | :invalid_query}, state}
  def handle_call({:software, :query, name, params}, _from, state) do
    response = SoftwareQuery.handle_query(name, params)

    {:reply, response, state}
  end
end