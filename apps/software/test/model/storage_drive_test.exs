defmodule Helix.Software.Model.StorageDriveTest do
  use ExUnit.Case, async: true

  alias Ecto.Changeset
  alias HELL.TestHelper.Random
  alias Helix.Software.Model.StorageDrive

  defp generate_params() do
    %{
      storage_id: Random.pk(),
      drive_id: Random.number()
    }
  end

  test "requires storage_id and drive_id" do
    cs = StorageDrive.create_changeset(%{})

    assert :storage_id in Keyword.keys(cs.errors)
    assert :drive_id in Keyword.keys(cs.errors)
  end

  test "uses storage_id and drive_id from params" do
    params = generate_params()
    cs = StorageDrive.create_changeset(params)

    assert params.storage_id == Changeset.get_field(cs, :storage_id)
    assert params.drive_id == Changeset.get_field(cs, :drive_id)
  end
end