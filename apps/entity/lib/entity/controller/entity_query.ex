defmodule Helix.Entity.Controller.EntityQuery do

  alias Helix.Entity.Model.Entity
  alias Helix.Entity.Model.EntityComponent
  alias Helix.Entity.Model.EntityServer
  alias Helix.Entity.Repo

  def handle_query("getEntity", %{entity_id: id}) do
    result =
      id
      |> Entity.Query.by_id()
      |> Repo.one()

    case result do
      nil ->
        {:error, :notfound}
      entity_type ->
        {:ok, entity_type}
    end
  end

  def handle_query("getComponents", %{entity_id: id}) do
    components =
      id
      |> EntityComponent.Query.from_entity()
      |> EntityComponent.Query.select_component_id()
      |> Repo.all()

    {:ok, components}
  end

  def handle_query("getServers", %{entity_id: id}) do
    servers =
      id
      |> EntityServer.Query.from_entity()
      |> EntityServer.Query.select_server_id()
      |> Repo.all()

    {:ok, servers}
  end

  def handle_query(_, _),
    do: {:error, :invalid_query}
end