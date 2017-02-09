defmodule Helix.Entity.Controller.EntityQuery do

  alias Helix.Entity.Model.Entity
  alias Helix.Entity.Repo

  def handle_query("getEntity", %{id: entity_id}) do
    # FIXME: add changeset validations T420
    result =
      entity_id
      |> Entity.Query.by_id()
      |> Repo.one()

    case result do
      nil ->
        {:error, :notfound}
      entity_type ->
        {:ok, entity_type}
    end
  end

  def handle_query(_, _),
    do: {:error, :invalid_query}
end