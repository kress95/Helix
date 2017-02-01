defmodule Helix.Software.Model.FileModuleTest do

  use ExUnit.Case, async: true

  alias Ecto.Changeset
  alias HELL.TestHelper.Random
  alias Helix.Software.Model.FileModule

  def generate_params() do
    %{
      file_id: Random.pk(),
      module_role_id: Random.pk(),
      module_version: Random.number(min: 1)
    }
  end

  describe "creating file_module changeset" do
    test "requires file_id, module_role_id and module_version" do
      cs = FileModule.create_changeset(%{})

      assert :file_id in Keyword.keys(cs.errors)
      assert :module_role_id in Keyword.keys(cs.errors)
      assert :module_version in Keyword.keys(cs.errors)
    end

    test "requires that module_version is a positive integer" do
      params = generate_params()
      params = %{params | module_version: Random.number(max: 0)}
      cs = FileModule.create_changeset(params)

      assert :module_version in Keyword.keys(cs.errors)
    end

    test "uses file_id, module_role_id and module_version from params" do
      params = generate_params()
      cs = FileModule.create_changeset(params)

      assert params.file_id == Changeset.get_field(cs, :file_id)
      assert params.module_role_id == Changeset.get_field(cs, :module_role_id)
      assert params.module_version == Changeset.get_field(cs, :module_version)
    end
  end

  describe "updating file_module changeset" do
    test "replaces the module_version" do
      params1 = generate_params()
      params2 = generate_params()
      cs1 = FileModule.create_changeset(params1)
      cs2 = FileModule.update_changeset(cs1, params2)

      assert params1.module_version == Changeset.get_field(cs1, :module_version)
      assert params2.module_version == Changeset.get_field(cs2, :module_version)
    end

    test "requires that module_version is a positive integer" do
      params1 = generate_params()
      params2 = %{params1 | module_version: Random.number(max: 0)}
      cs1 = FileModule.create_changeset(params1)
      cs2 = FileModule.update_changeset(cs1, params2)

      refute :module_version in Keyword.keys(cs1.errors)
      assert :module_version in Keyword.keys(cs2.errors)
    end
  end
end
