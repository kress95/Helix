defmodule Helix.Hardware.Controller.ComponentTest do

  use ExUnit.Case, async: true

  alias Helix.Hardware.Controller.Component, as: ComponentController
  alias Helix.Hardware.Model.Component
  alias Helix.Hardware.Repo

  alias Helix.Hardware.Factory

  describe "fetching component" do
    test "succeeds by id" do
      c = Factory.insert(:component)
      assert {:ok, _} = ComponentController.find(c.component_id)
    end

    test "fails when component doesn't exists" do
      c = Factory.build(:component)
      assert {:error, :notfound} == ComponentController.find(c.component_id)
    end
  end

  test "delete is idempotent" do
    component = Factory.insert(:component)

    assert Repo.get_by(Component, component_id: component.component_id)
    ComponentController.delete(component.component_id)
    ComponentController.delete(component.component_id)
    refute Repo.get_by(Component, component_id: component.component_id)
  end
end