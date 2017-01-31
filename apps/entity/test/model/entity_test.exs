defmodule Helix.Entity.Model.EntityTest do

  use ExUnit.Case, async: true

  alias Ecto.Changeset
  alias HELL.TestHelper.Random
  alias Helix.Entity.Model.Entity

  defp generate_params() do
    %{entity_type: Random.string(), entity_id: Random.pk()}
  end

  test "requires entity_type and entity_id" do
    cs = Entity.create_changeset(%{})

    assert :entity_type in Keyword.keys(cs.errors)
    assert :entity_id in Keyword.keys(cs.errors)
  end

  test "uses entity_type and entity_id from params" do
    params = generate_params()
    cs = Entity.create_changeset(params)

    assert params.entity_type == Changeset.get_field(cs, :entity_type)
    assert params.entity_id == Changeset.get_field(cs, :entity_id)
  end
end