defmodule Helix.Server.Controller.ServerQuery do

  alias Helix.Server.Model.Server
  alias Helix.Server.Repo

  def handle_query("getServer", %{server_id: id}) do
    # FIXME: add changeset validations T420
    result =
      id
      |> Server.Query.by_id()
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