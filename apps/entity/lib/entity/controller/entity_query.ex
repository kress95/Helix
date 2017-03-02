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
    case EntityService.list_components(entity_id) do
      {:ok, components} ->
        components
        |> Enum.map(&(%{component_id: &1.component_id}))
        |> Enum.reject(fn msg ->
          {_, {:ok, result}} = Broker.call("hardware.component.linked?", msg)
          result.linked?
        end)
        |> Enum.map(&(&1.component_id))
      error ->
        error
    end
  end

  def handle_query(_, _),
    do: {:error, :invalid_query}
end