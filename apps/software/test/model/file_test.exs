defmodule Helix.Software.Model.FileTest do

  use ExUnit.Case, async: true

  alias Ecto.Changeset
  alias HELL.TestHelper.Random
  alias Helix.Software.Model.File

  def generate_params() do
    %{
      name: Random.string(),
      file_path: Random.string(),
      file_size: Random.number(1..100),
      file_type: Random.string(),
      storage_id: Random.pk()
    }
  end

  describe "creating file changeset" do
    test "requires name, file_path, file_type, file_size and storage_id" do
      cs = File.create_changeset(%{})

      assert :name in Keyword.keys(cs.errors)
      assert :file_path in Keyword.keys(cs.errors)
      assert :file_type in Keyword.keys(cs.errors)
      assert :file_size in Keyword.keys(cs.errors)
      assert :storage_id in Keyword.keys(cs.errors)
    end

    test "requires that file_size is a positive integer" do
      params = generate_params()
      params = %{params | file_size: Random.number(max: 0)}
      cs = File.create_changeset(params)

      assert :file_size in Keyword.keys(cs.errors)
    end

    test "uses data from params" do
      params = generate_params()
      cs = File.create_changeset(params)

      assert params.name == Changeset.get_field(cs, :name)
      assert params.file_path == Changeset.get_field(cs, :file_path)
      assert params.file_size == Changeset.get_field(cs, :file_size)
      assert params.file_type == Changeset.get_field(cs, :file_type)
      assert params.storage_id == Changeset.get_field(cs, :storage_id)
    end
  end

  test "updating file changeset replaces its fields" do
    params1 = generate_params()
    params2 = generate_params()
    cs1 = File.create_changeset(params1)
    cs2 = File.update_changeset(cs1, params2)

    # params1 and cs1 fields are matching
    assert params1.name == Changeset.get_field(cs1, :name)
    assert params1.file_path == Changeset.get_field(cs1, :file_path)
    assert params1.storage_id == Changeset.get_field(cs1, :storage_id)

    # params2 and cs2 fields are matching
    assert params2.name == Changeset.get_field(cs2, :name)
    assert params2.file_path == Changeset.get_field(cs2, :file_path)
    assert params2.storage_id == Changeset.get_field(cs2, :storage_id)
  end
end