defmodule HELM.Hardware.Controller.MotherboardSlotTest do
  use ExUnit.Case

  alias HELL.IPv6
  alias HELL.TestHelper.Random, as: HRand
  alias HELM.Hardware.Repo
  alias HELM.Hardware.Model.ComponentType, as: MdlCompType
  alias HELM.Hardware.Controller.ComponentSpec, as: CtrlCompSpec
  alias HELM.Hardware.Controller.Component, as: CtrlComps
  alias HELM.Hardware.Controller.Motherboard, as: CtrlMobos
  alias HELM.Hardware.Controller.MotherboardSlot, as: CtrlMoboSlots

  @component_type HRand.string(min: 20)

  setup_all do
    %{component_type: @component_type}
    |> MdlCompType.create_changeset()
    |> Repo.insert!()

    :ok
  end

  setup do
    spec_payload = %{component_type: @component_type, spec: %{}}
    {:ok, comp_spec} = CtrlCompSpec.create(spec_payload)

    comp_payload = %{component_type: @component_type, spec_id: comp_spec.spec_id}
    {:ok, comp} = CtrlComps.create(comp_payload)
    {:ok, mobo} = CtrlMobos.create()

    payload = %{
      slot_internal_id: HRand.number(1..1024),
      motherboard_id: mobo.motherboard_id,
      link_component_type: @component_type,
      link_component_id: comp.component_id
    }

    clean_payload = %{
      slot_internal_id: HRand.number(1..1024),
      motherboard_id: mobo.motherboard_id,
      link_component_type: @component_type
    }

    locals = [
      payload: payload,
      clean_payload: clean_payload,
      comp_id: comp.component_id,
      spec_id: comp_spec.spec_id
    ]

    {:ok, locals}
  end

  test "create/1", %{payload: payload} do
    assert {:ok, _} = CtrlMoboSlots.create(payload)
  end

  describe "find/1" do
    test "success", %{payload: payload} do
      assert {:ok, mobo_slots} = CtrlMoboSlots.create(payload)
      assert {:ok, ^mobo_slots} = CtrlMoboSlots.find(mobo_slots.slot_id)
    end

    test "failure" do
      assert {:error, :notfound} = CtrlMoboSlots.find(IPv6.generate([]))
    end
  end

  describe "update/2" do
    test "change slot component", %{payload: payload, spec_id: spec_id} do
      comp_payload = %{component_type: @component_type, spec_id: spec_id}
      {:ok, comp} = CtrlComps.create(comp_payload)

      assert {:ok, mobo_slots} = CtrlMoboSlots.create(payload)

      payload2 = %{link_component_id: comp.component_id}
      assert {:ok, mobo_slots} = CtrlMoboSlots.update(mobo_slots.slot_id, payload2)
      assert mobo_slots.link_component_id == comp.component_id
    end

    test "slot not found" do
      assert {:error, :notfound} = CtrlMoboSlots.update(IPv6.generate([]), %{})
    end
  end

  test "delete/1 idempotency", %{payload: payload} do
    assert {:ok, mobo_slots} = CtrlMoboSlots.create(payload)
    assert :ok = CtrlMoboSlots.delete(mobo_slots.slot_id)
    assert :ok = CtrlMoboSlots.delete(mobo_slots.slot_id)
  end

  test "link/1 idempotency", %{clean_payload: payload, comp_id: comp_id} do
    assert {:ok, mobo_slots} = CtrlMoboSlots.create(payload)
    assert {:ok, _} = CtrlMoboSlots.link(mobo_slots.slot_id, comp_id)
    assert {:ok, _} = CtrlMoboSlots.link(mobo_slots.slot_id, comp_id)
  end

  test "unlink/1 idempotency", %{payload: payload} do
    assert {:ok, mobo_slots} = CtrlMoboSlots.create(payload)
    assert {:ok, _} = CtrlMoboSlots.unlink(mobo_slots.slot_id)
    assert {:ok, _} = CtrlMoboSlots.unlink(mobo_slots.slot_id)
  end
end