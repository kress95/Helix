defmodule Helix.Server.Controller.ServerQuery do

  alias HELF.Broker
  alias Helix.Server.Controller.ServerService

  def handle_query("getServer", %{id: server_id}) do
    # FIXME: add changeset validations T420
    case ServerService.find_server(server_id) do
      {:ok, server} ->
        msg = %{
          server_id: server.server_id,
          server_type: server.server_type,
          poi_id: server.poi_id,
          motherboard_id: server.motherboard_id
        }

        {:ok, msg}
      error ->
        error
    end
  end

  def handle_query("listPluggedComponents", %{id: server_id}) do
    # FIXME: add changeset validations T420
    # TODO: test this query ASAP
    with \
      {:ok, server} <- ServerService.find_server(server_id),
      msg = %{motherboard_id: server.motherboard_id},
      {_, {:ok, slots}} <- Broker.call("hardware.motherboard.slots", msg)
    do
      components = Enum.map(slots, &(&1.link_component_id))
      reply = %{list: components}

      {:ok, reply}
    else
      _ ->
        {:error, :notfound}
    end
  end

  def handle_query("listServers", %{entity_id: entity_id}) do
    # FIXME: add changeset validations T420
    # TODO: test this query ASAP
    {_, result} = Broker.call("entity.list.servers", entity_id)

    case result do
      {:ok, component_list} ->
        {:ok, %{list: component_list}}
      {:error, error} ->
        {:error, error}
      error ->
        {:error, error}
    end
  end

  # TODO: add this query once we define server resources
  # def handle_query("getServerResources", %{id: server_id}) do
  #   {:error, :uninplemented}
  # end

  def handle_query(_, _),
    do: {:error, :invalid_query}
end