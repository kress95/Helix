defmodule Helix.Server.Model.ServerTypeTest do
  use ExUnit.Case, async: true

  alias Ecto.Changeset
  alias HELL.TestHelper.Random
  alias Helix.Server.Model.ServerType

  defp generate_params() do
    %{server_type: Random.string(min: 20)}
  end

  test "requires server_type" do
    cs = ServerType.create_changeset(%{})

    assert :server_type in Keyword.keys(cs.errors)
  end

  test "uses server_type from params" do
    params = generate_params()
    cs = ServerType.create_changeset(params)

    assert params.server_type == Changeset.get_field(cs, :server_type)
  end
end