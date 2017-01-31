defmodule Helix.Entity.Model.EntityServerTest do

  use ExUnit.Case, async: true

  alias Ecto.Changeset
  alias HELL.TestHelper.Random
  alias Helix.Entity.Model.EntityServer

  defp generate_params() do
    %{entity_id: Random.pk(), server_id: Random.pk()}
  end

  test "requires entity_id and server_id" do
    cs = EntityServer.create_changeset(%{})

    assert :entity_id in Keyword.keys(cs.errors)
    assert :server_id in Keyword.keys(cs.errors)
  end

  test "links server to entity" do
    params = generate_params()
    cs = EntityServer.create_changeset(params)

    assert params.entity_id == Changeset.get_field(cs, :entity_id)
    assert params.server_id == Changeset.get_field(cs, :server_id)
  end
end