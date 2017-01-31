defmodule Helix.Server.Model.ServerTest do
  use ExUnit.Case, async: true

  alias Ecto.Changeset
  alias HELL.TestHelper.Random
  alias Helix.Server.Model.Server

  defp generate_params() do
    %{
      server_type: Random.string(),
      motherboard_id: Random.pk(),
      poi_id: Random.pk()
    }
  end

  describe "creating server changeset" do
    test "requires server_type" do
      cs = Server.create_changeset(%{})

      assert :server_type in Keyword.keys(cs.errors)
    end

    test "doesn't requires motherboard_id and poi_id" do
      cs = Server.create_changeset(%{})

      refute :motherboard_id in Keyword.keys(cs.errors)
      refute :poi_id in Keyword.keys(cs.errors)
    end

    test "uses server_type, motherboard_id and server_type from params" do
      params = generate_params()
      cs = Server.create_changeset(params)

      assert params.server_type == Changeset.get_field(cs, :server_type)
      assert params.motherboard_id == Changeset.get_field(cs, :motherboard_id)
      assert params.poi_id == Changeset.get_field(cs, :poi_id)
    end
  end

  test "updating server changeset replaces its fields" do
    params1 = generate_params()
    params2 = generate_params()

    cs1 = Server.create_changeset(params1)
    cs2 = Server.update_changeset(cs1, params2)

    # params1 and cs1 fields are matching
    assert params1.motherboard_id == Changeset.get_field(cs1, :motherboard_id)
    assert params1.poi_id == Changeset.get_field(cs1, :poi_id)

    # params2 and cs2 fields are matching
    assert params2.motherboard_id == Changeset.get_field(cs2, :motherboard_id)
    assert params2.poi_id == Changeset.get_field(cs2, :poi_id)
  end
end