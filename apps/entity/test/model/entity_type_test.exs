defmodule Helix.Entity.Model.EntityTypeTest do

  use ExUnit.Case, async: true

  alias Ecto.Changeset
  alias HELL.TestHelper.Random
  alias Helix.Entity.Model.EntityType

  def generate_params do
    %{entity_type: Random.string(min: 20)}
  end

  test "requires entity_type" do
    cs = EntityType.create_changeset(%{})

    assert :entity_type in Keyword.keys(cs.errors)
  end

  test "uses entity_type from params" do
    params = generate_params()
    cs = EntityType.create_changeset(params)

    assert params.entity_type == Changeset.get_field(cs, :entity_type)
  end
end