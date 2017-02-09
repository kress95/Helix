defmodule Helix.Entity.Controller.EntityQueryTest do

  use ExUnit.Case, async: true

  alias HELL.TestHelper.Random
  alias HELF.Broker
  alias Helix.Entity.Controller.Entity, as: EntityController
  alias Helix.Entity.Model.EntityType
  alias Helix.Entity.Repo

  setup_all do
    entity_types = Repo.all(EntityType)
    [entity_types: entity_types]
  end

  setup context do
    entity_type = Enum.random(context.entity_types)
    {:ok, entity_type: entity_type.entity_type}
  end

  def create_entity(entity_type) do
    params = %{entity_id: Random.pk(), entity_type: entity_type}
    {:ok, entity} = EntityController.create(params)
    entity
  end

  describe "querying getEntity" do
    test "succeeds when entity exists", context do
      entity1 = create_entity(context.entity_type)

      msg = %{query: "getEntity", params: %{id: entity1.entity_id}}

      {_, {:ok, entity2}} = Broker.call("entity.query", msg)

      assert entity1 == entity2
    end

    test "fails when account doesn't exists" do
      msg = %{query: "getEntity", params: %{id: Random.pk()}}
      {_, result} = Broker.call("entity.query", msg)

      assert {:error, :notfound} == result
    end
  end

  test "querying fails with invalid query" do
    msg = %{query: Random.string(), params: %{}}

    {_, result} = Broker.call("entity.query", msg)

    assert {:error, :invalid_query} == result
  end
end