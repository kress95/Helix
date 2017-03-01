defmodule Helix.Entity.Controller.EntityMotherboardTest do

  use ExUnit.Case, async: true

  alias HELL.TestHelper.Random
  alias Helix.Entity.Controller.Entity, as: EntityController
  alias Helix.Entity.Controller.EntityMotherboard, as: EntityMotherboardController
  alias Helix.Entity.Model.Entity
  alias Helix.Entity.Model.EntityType
  alias Helix.Entity.Repo

  setup_all do
    entity_type =
      EntityType
      |> Repo.all()
      |> Enum.random()

    {:ok, entity_type: entity_type.entity_type}
  end

  defp create_entity(entity_type) do
    params = %{
      entity_type: entity_type,
      entity_id: Random.pk()
    }

    entity =
      params
      |> Entity.create_changeset()
      |> Repo.insert!()

    entity.entity_id
  end

  defp create_motherboards(entity_id) do
    motherboards = Enum.map(0..Random.number(1..10), fn _ -> Random.pk() end)
    Enum.each(motherboards, fn motherboard_id ->
      {:ok, _} = EntityMotherboardController.create(entity_id, motherboard_id)
    end)
    motherboards
  end

  test "creating adds entity ownership over motherboards", context do
    entity_id = create_entity(context.entity_type)
    motherboards = create_motherboards(entity_id)

    motherboards1 = Enum.into(motherboards, MapSet.new())
    motherboards2 =
      entity_id
      |> EntityMotherboardController.find()
      |> Enum.map(&(&1.motherboard_id))
      |> Enum.into(MapSet.new())

    # motherboards are linked
    assert MapSet.equal?(motherboards1, motherboards2)
  end

  test "fetching yields an empty list when no motherboard is owned", context do
    entity_id = create_entity(context.entity_type)
    assert [] == EntityMotherboardController.find(entity_id)
  end

  test "fetching motherboards from a non existent entity yields an empty list" do
    assert [] == EntityMotherboardController.find(Random.pk())
  end

  test "deleting the entity removes its motherboard ownership", context do
    entity_id = create_entity(context.entity_type)
    create_motherboards(entity_id)

    # motherboards are owned
    refute [] == EntityMotherboardController.find(entity_id)

    EntityController.delete(entity_id)

    # motherboards aren't owned anymore
    assert [] == EntityMotherboardController.find(entity_id)
  end

  test "deleting is idempotent", context do
    entity_id = create_entity(context.entity_type)
    motherboard_id = Random.pk()

    {:ok, _} = EntityMotherboardController.create(entity_id, motherboard_id)

    # motherboards are owned
    refute [] == EntityMotherboardController.find(entity_id)

    :ok = EntityMotherboardController.delete(entity_id, motherboard_id)
    :ok = EntityMotherboardController.delete(entity_id, motherboard_id)

    # motherboards aren't owned anymore
    assert [] == EntityMotherboardController.find(entity_id)
  end
end