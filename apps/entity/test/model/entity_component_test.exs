defmodule Helix.Entity.Model.EntityComponentTest do

  use ExUnit.Case, async: true

  alias Ecto.Changeset
  alias HELL.TestHelper.Random
  alias Helix.Entity.Model.EntityComponent

  defp generate_params() do
    %{entity_id: Random.pk(), component_id: Random.pk()}
  end

  test "requires entity_id and component_id" do
    cs = EntityComponent.create_changeset(%{})

    assert :entity_id in Keyword.keys(cs.errors)
    assert :component_id in Keyword.keys(cs.errors)
  end

  test "links component to entity" do
    params = generate_params()
    cs = EntityComponent.create_changeset(params)

    assert params.entity_id == Changeset.get_field(cs, :entity_id)
    assert params.component_id == Changeset.get_field(cs, :component_id)
  end
end