defmodule Helix.Entity.Controller.EntityQuery do

  alias HELF.Broker
  alias Helix.Entity.Controller.EntityService

  def handle_query("getEntity", %{id: entity_id}) do
    # FIXME: add changeset validations T420
    case EntityService.find_entity(entity_id) do
      {:ok, entity} ->
        msg = %{
          entity_id: entity.entity_id,
          entity_type: entity.entity_type
        }

        {:ok, msg}
      error ->
        error
    end
  end

  def handle_query("listUnpluggedComponents", %{id: entity_id}) do
    # FIXME: add changeset validations T420
    # TODO: test this query ASAP
    get_motherboard_id =
      fn server_id ->
        req = %{server_id: server_id}
        {_, {:ok, res}} = Broker.call("server.motherboard.fetch", req)

        res.motherboard_id
      end

    get_unused_components =
      fn component_id_list ->
        req = %{component_id_list: component_id_list}
        {_, {:ok, res}} = Broker.call("hardware.component.filter_unused", req)

        res.component_id_list
      end

    motherboards =
      entity_id
      |> EntityService.list_servers()
      |> Enum.map(get_motherboard_id)

    components =
      entity_id
      |> EntityService.list_components()
      |> Kernel.--(motherboards)
      |> get_unused_components.()

    {:ok, %{list: components}}
  end

  def handle_query(_, _),
    do: {:error, :invalid_query}
end