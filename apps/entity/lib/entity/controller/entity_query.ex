defmodule Helix.Entity.Controller.EntityQuery do

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

  def handle_query(_, _),
    do: {:error, :invalid_query}
end