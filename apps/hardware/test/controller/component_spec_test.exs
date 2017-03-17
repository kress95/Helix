defmodule Helix.Hardware.Controller.ComponentSpecTest do

  use ExUnit.Case, async: true

  alias Helix.Hardware.Controller.ComponentSpec, as: ComponentSpecController
  alias Helix.Hardware.Model.ComponentSpec

  alias Helix.Hardware.Factory

  describe "fetching" do
    test "returns a record based on its identification" do
      cs = Factory.insert(:component_spec)
      assert %ComponentSpec{} = ComponentSpecController.fetch(cs.spec_id)
    end

    test "returns nil if spec with id doesn't exist" do
      bogus = Factory.build(:component_spec)
      refute ComponentSpecController.fetch(bogus.spec_id)
    end
  end

  test "updating changes spec map" do
    cs = Factory.insert(:component_spec)
    params = %{spec: %{"test" => Burette.Color.name()}}

    {:ok, cs} = ComponentSpecController.update(cs, params)

    assert params.spec == cs.spec
  end

  describe "deleting" do
    test "is idempotent" do
      cs = Factory.insert(:component_spec)

      assert ComponentSpecController.fetch(cs.spec_id)

      ComponentSpecController.delete(cs.spec_id)
      ComponentSpecController.delete(cs.spec_id)

      refute ComponentSpecController.fetch(cs.spec_id)
    end

    test "can be done by its id or its struct" do
      cs = Factory.insert(:component_spec)
      assert ComponentSpecController.fetch(cs.spec_id)
      ComponentSpecController.delete(cs)
      refute ComponentSpecController.fetch(cs.spec_id)

      cs = Factory.insert(:component_spec)
      assert ComponentSpecController.fetch(cs.spec_id)
      ComponentSpecController.delete(cs.spec_id)
      refute ComponentSpecController.fetch(cs.spec_id)
    end
  end
end