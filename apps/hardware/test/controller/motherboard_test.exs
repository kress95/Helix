defmodule Helix.Hardware.Controller.MotherboardTest do

  use ExUnit.Case, async: true

  alias Helix.Hardware.Controller.Motherboard, as: MotherboardController
  alias Helix.Hardware.Controller.MotherboardSlot, as: MotherboardSlotController
  alias Helix.Hardware.Model.Motherboard

  alias Helix.Hardware.Factory

  describe "fetching" do
    test "returns a record based on its identification" do
      mobo = Factory.insert(:motherboard)
      assert %Motherboard{} = MotherboardController.fetch(mobo.motherboard_id)
    end

    test "returns nil if spec with id doesn't exist" do
      bogus = Factory.build(:motherboard)
      refute MotherboardController.fetch(bogus.motherboard_id)
    end
  end

  test "unlinking every component from a motherboard" do
    mobo = Factory.insert(:motherboard)

    mobo.slots
    |> Enum.take_random(3)
    |> Enum.each(fn slot ->
      type = slot.link_component_type
      component = Factory.component_of_type(type)

      MotherboardSlotController.link(slot, component)
    end)

    MotherboardController.unlink_components_from_motherboard(mobo)

    non_empty_slots =
      mobo
      |> MotherboardController.get_slots()
      |> Enum.reject(&is_nil(&1.link_component_id))

    assert [] == non_empty_slots
  end

  describe "deleting" do
    test "is idempotent" do
      mobo = Factory.insert(:motherboard)

      assert %Motherboard{} = MotherboardController.fetch(mobo.motherboard_id)

      MotherboardController.delete(mobo.motherboard_id)
      MotherboardController.delete(mobo.motherboard_id)

      refute MotherboardController.fetch(mobo.motherboard_id)
    end

    test "can be done by its id or its struct" do
      mobo = Factory.insert(:motherboard)
      assert MotherboardController.fetch(mobo.motherboard_id)
      MotherboardController.delete(mobo)
      refute MotherboardController.fetch(mobo.motherboard_id)

      mobo = Factory.insert(:motherboard)
      assert MotherboardController.fetch(mobo.motherboard_id)
      MotherboardController.delete(mobo.motherboard_id)
      refute MotherboardController.fetch(mobo.motherboard_id)
    end

    test "removes its slots" do
      mobo = Factory.insert(:motherboard)

      refute [] == MotherboardController.get_slots(mobo.motherboard_id)

      MotherboardController.delete(mobo.motherboard_id)

      assert [] == MotherboardController.get_slots(mobo.motherboard_id)
    end
  end
end