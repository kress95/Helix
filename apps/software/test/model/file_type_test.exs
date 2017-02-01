defmodule Helix.Software.Model.FileTypeTest do

  use ExUnit.Case, async: true

  alias Ecto.Changeset
  alias HELL.TestHelper.Random
  alias Helix.Software.Model.FileType

  def generate_params() do
    %{
      file_type: Random.string(min: 20),
      extension: Random.string(max: 6)
    }
  end

  test "requires file_type and extension" do
    cs = FileType.create_changeset(%{})

    assert :file_type in Keyword.keys(cs.errors)
    assert :extension in Keyword.keys(cs.errors)
  end

  test "uses entity_type and extension from params" do
    params = generate_params()
    cs = FileType.create_changeset(params)

    assert params.file_type == Changeset.get_field(cs, :file_type)
    assert params.extension == Changeset.get_field(cs, :extension)
  end
end