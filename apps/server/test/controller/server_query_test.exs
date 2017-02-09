defmodule Helix.Server.Controller.ServerQueryTest do

  use ExUnit.Case, async: true

  alias HELF.Broker
  alias HELL.TestHelper.Random
  alias Helix.Server.Controller.Server, as: ServerController
  alias Helix.Server.Model.ServerType
  alias Helix.Server.Repo

  setup_all do
    server_types = Repo.all(ServerType)
    {:ok, server_types: server_types}
  end

  setup context do
    server_type = Enum.random(context.server_types)
    {:ok, server_type: server_type.server_type}
  end

  defp create_server(server_type) do
    params = %{server_type: server_type}
    {:ok, server} = ServerController.create(params)
    server
  end

  describe "querying getServer by id" do
    test "returns a map with server information", context do
      server = create_server(context.server_type)

      expecting = %{
        server_id: server.server_id,
        server_type: server.server_type,
        poi_id: server.poi_id,
        motherboard_id: server.motherboard_id
      }

      msg = %{
        query: "getServer",
        params: %{id: server.server_id}
      }

      {_, {:ok, result}} = Broker.call("server.query", msg)

      assert expecting == result
    end

    test "fails when server doesn't exist" do
      msg = %{
        query: "getServer",
        params: %{id: Random.pk()}
      }

      {_, result} = Broker.call("server.query", msg)

      assert {:error, :notfound} == result
    end
  end

  # TODO: add this test after adding the query
  # describe "querying getServerResources" do
  # end

  test "querying fails with invalid query" do
    msg = %{query: Random.string(), params: %{}}

    {_, result} = Broker.call("server.query", msg)

    assert {:error, :invalid_query} == result
  end
end