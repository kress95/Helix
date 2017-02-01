defmodule Helix.Software.Model.ModuleRoleTest do

  use ExUnit.Case, async: true

  alias Ecto.Changeset
  alias HELL.TestHelper.Random
  alias Helix.Software.Model.ModuleRole

  defp generate_params() do
    %{
      module_role: Random.string(min: 20),
      file_type: Random.string(min: 20),
    }
  end

  test "requires module_role and file_type" do
    cs = ModuleRole.create_changeset(%{})

    assert :module_role in Keyword.keys(cs.errors)
    assert :file_type in Keyword.keys(cs.errors)
  end

  test "uses module_role and file_type from params" do
    params = generate_params()
    cs = ModuleRole.create_changeset(params)

    assert params.module_role == Changeset.get_field(cs, :module_role)
    assert params.file_type == Changeset.get_field(cs, :file_type)
  end
end