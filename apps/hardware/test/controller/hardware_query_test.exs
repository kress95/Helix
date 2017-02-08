defmodule Helix.Hardware.Controller.HardwareQueryTest do
  # WIP

  use ExUnit.Case, async: false

  alias HELF.Broker
  alias HELL.TestHelper.Random
  alias Helix.Hardware.Controller.Component, as: ComponentController
  alias Helix.Hardware.Controller.Motherboard, as: MotherboardController
  alias Helix.Hardware.Model.ComponentSpec
  alias Helix.Hardware.Repo

  import Ecto.Query, only: [where: 3]

  setup_all do
    mobo_spec = Repo.get_by(ComponentSpec, spec_id: "MOBO01")
    spec_types = ["cpu", "ram", "hdd", "nic"]

    specs =
      Enum.map(spec_types, fn spec_type ->
        spec_id =
          ComponentSpec
          |> where([cs], cs.component_type == ^spec_type)
          |> Repo.all()
          |> Enum.random()

        spec_id
      end)

    {:ok, specs: specs, mobo_spec: mobo_spec}
  end

  describe "query getComponent" do
    test "by id", context do
      {:ok, component} =
        context.specs
        |> Enum.random()
        |> ComponentController.create_from_spec()

      msg = %{
        query: "getComponent",
        params: %{id: component.component_id}
      }

      {_, {:ok, result}} = Broker.call("hardware.query", msg)

      assert component.component_id == result.component_id
    end

    test "fails when component doesn't exists" do
      msg = %{
        query: "getComponent",
        params: %{id: Random.pk()}
      }

      {_, result} = Broker.call("hardware.query", msg)

      assert {:error, :notfound} == result
    end
  end

  test "query listMotherboardSlots by id", context do
    {:ok, mobo} = MotherboardController.create_from_spec(context.mobo_spec)

    slots =
      mobo
      |> MotherboardController.get_slots()
      |> Enum.map(fn slot ->
        %{
          slot_id: slot.slot_id,
          link_component_id: slot.link_component_id,
          link_component_type: slot.link_component_type,
          slot_internal_id: slot.slot_internal_id
        }
      end)

    msg = %{
      query: "listMotherboardSlots",
      params: %{id: mobo.motherboard_id}
    }

    {_, {:ok, result}} = Broker.call("hardware.query", msg)

    assert slots == result.list
  end

  test "querying fails with invalid query" do
    msg = %{query: Random.string(), params: %{}}

    {_, result} = Broker.call("hardware.query", msg)

    assert {:error, :invalid_query} == result
  end
end
