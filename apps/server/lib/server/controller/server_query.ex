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

  def handle_query("listServers", %{id: entity_id}) do
    # FIXME: add changeset validations T420
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