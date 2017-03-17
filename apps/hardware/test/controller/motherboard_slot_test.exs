defmodule Helix.Hardware.Controller.MotherboardSlotTest do

  use ExUnit.Case, async: true

  alias Helix.Hardware.Controller.MotherboardSlot, as: MotherboardSlotController
  alias Helix.Hardware.Model.MotherboardSlot

  alias Helix.Hardware.Factory

  defp slot_for(motherboard, component) do
    motherboard.slots
    |> Enum.filter(&(&1.link_component_type == component.component_type))
    |> Enum.random()
  end

  describe "fetching" do
    test "returns a record based on its identification" do
      slot = Factory.insert(:motherboard_slot)
      assert %MotherboardSlot{} = MotherboardSlotController.fetch(slot.slot_id)
    end

    test "returns nil if slot with id doesn't exist" do
      slot = Factory.build(:motherboard_slot)
      refute MotherboardSlotController.fetch(slot.slot_id)
    end
  end

  describe "linking" do
    test "links a component to a motherboard slot" do
      component = Factory.insert(:component)
      slot =
        :motherboard
        |> Factory.insert()
        |> slot_for(component)

      {:ok, slot} = MotherboardSlotController.link(slot, component)
      assert component.component_id == slot.link_component_id
    end

    test "fails when slot is already in use" do
      cpu1 = Factory.insert(:cpu)
      cpu2 = Factory.insert(:cpu)
      slot =
        :motherboard
        |> Factory.insert()
        |> slot_for(cpu1.component)

      {:ok, slot} = MotherboardSlotController.link(slot, cpu1.component)

      assert {:error, :slot_already_linked} ==
        MotherboardSlotController.link(slot, cpu2.component)
    end

    test "fails when component is already in use" do
      component = Factory.insert(:component)
      slot1 =
        :motherboard
        |> Factory.insert()
        |> slot_for(component)
      slot2 =
        :motherboard
        |> Factory.insert()
        |> slot_for(component)

      {:ok, _} = MotherboardSlotController.link(slot1, component)

      assert {:error, :component_already_linked} ==
        MotherboardSlotController.link(slot2, component)
    end
  end

  test "unlinking is idempotent" do
    component = Factory.insert(:component)
    slot =
      :motherboard
      |> Factory.insert()
      |> slot_for(component)

    {:ok, slot} = MotherboardSlotController.link(slot, component)
    assert slot.link_component_id

    assert {:ok, _} = MotherboardSlotController.unlink(slot)
    assert {:ok, _} = MotherboardSlotController.unlink(slot)

    slot = MotherboardSlotController.fetch(slot.slot_id)
    refute slot.link_component_id
  end
end