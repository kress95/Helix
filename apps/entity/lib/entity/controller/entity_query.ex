defmodule Helix.Entity.Controller.EntityQuery do

  alias Helix.Entity.Model.Entity
  alias Helix.Entity.Model.EntityComponent
  alias Helix.Entity.Model.EntityServer
  alias Helix.Entity.Repo

  def handle_query("getEntityType", %{id: id}) do
    result =
      id
      |> Entity.Query.by_id()
      |> Entity.Query.select_entity_type()
      |> Repo.one()

    case result do
      nil ->
        {:error, :notfound}
      entity_type ->
        {:ok, entity_type}
    end
  end

  def handle_query("getEntityComponents", %{id: id}) do
    result =
      id
      |> EntityComponent.Query.from_entity()
      |> EntityComponent.Query.select_component_id()
      |> Repo.all()

    case result do
      [] ->
        {:error, :notfound}
      components ->
        {:ok, components}
    end
  end

  def handle_query("getEntityServers", %{id: id}) do
    result =
      id
      |> EntityServer.Query.from_entity()
      |> EntityServer.Query.select_server_id()
      |> Repo.all()

    case result do
      [] ->
        {:error, :notfound}
      servers ->
        {:ok, servers}
    end
  end

  def handle_query(_, _),
    do: {:error, :invalid_query}
end