defmodule Helix.Server.Controller.ServerQuery do

  alias Helix.Server.Model.Server
  alias Helix.Server.Repo

  def handle_query("getPOIID", %{id: id}) do
    # FIXME: add changeset validations T420
    result =
      id
      |> Server.Query.by_id()
      |> Server.Query.select_poi_id()
      |> Repo.one()

    case result do
      nil ->
        {:error, :notfound}
      poi_id ->
        {:ok, poi_id}
    end
  end

  def handle_query("getAttachedMotherboardID", %{id: id}) do
    # FIXME: add changeset validations T420
    result =
      id
      |> Server.Query.by_id()
      |> Server.Query.select_motherboard_id()
      |> Repo.one()

    case result do
      nil ->
        {:error, :notfound}
      mobo_id ->
        {:ok, mobo_id}
    end
  end

  def handle_query("getServerType", %{id: id}) do
    # FIXME: add changeset validations T420
    result =
      id
      |> Server.Query.by_id()
      |> Server.Query.select_server_type()
      |> Repo.one()

    case result do
      nil ->
        {:error, :notfound}
      server_type ->
        {:ok, server_type}
    end
  end

  def handle_query(_, _),
    do: {:error, :invalid_query}
end