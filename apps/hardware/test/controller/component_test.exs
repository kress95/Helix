defmodule Helix.Hardware.Controller.ComponentTest do

  use ExUnit.Case, async: true

  alias Helix.Hardware.Controller.Component, as: ComponentController
  alias Helix.Hardware.Model.Component

  alias Helix.Hardware.Factory

  describe "fetching" do
    test "returns a record based on its identification" do
      c = Factory.insert(:component)
      assert %Component{} = ComponentController.fetch(c.component_id)
    end

    test "returns nil if spec with id doesn't exist" do
      bogus = Factory.build(:component)
      refute ComponentController.fetch(bogus.component_id)
    end
  end

  describe "deleting" do
    test "is idempotent" do
      component = Factory.insert(:component)

      assert ComponentController.fetch(component.component_id)

      ComponentController.delete(component.component_id)
      ComponentController.delete(component.component_id)

      refute ComponentController.fetch(component.component_id)
    end

    test "can be done by its id or its struct" do
      component = Factory.insert(:component)
      assert ComponentController.fetch(component.component_id)
      ComponentController.delete(component)
      refute ComponentController.fetch(component.component_id)

      component = Factory.insert(:component)
      assert ComponentController.fetch(component.component_id)
      ComponentController.delete(component.component_id)
      refute ComponentController.fetch(component.component_id)
    end
  end
end