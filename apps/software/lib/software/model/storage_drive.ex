defmodule Helix.Software.Model.StorageDrive do

  use Ecto.Schema

  alias HELL.PK
  alias Helix.Software.Model.Storage

  import Ecto.Changeset

  @type t :: %__MODULE__{
    storage_id: PK.t,
    storage: Storage.t,
    drive_id: PK.t
  }

  @type creation_params :: %{storage_id: PK.t}

  @creation_fields ~w/storage_id/a

  @primary_key false
  schema "storage_drives" do
    field :storage_id, PK,
      primary_key: true
    field :drive_id, PK,
      primary_key: true

    belongs_to :storage, Storage,
      foreign_key: :storage_id,
      references: :storage_id,
      type: HELL.PK,
      define_field: false
  end

  @spec create_changeset(creation_params) :: Ecto.Changeset.t
  def create_changeset(params) do
    %__MODULE__{}
    |> cast(params, @creation_fields)
    |> put_primary_key()
    |> validate_required(@creation_fields)
  end

  @spec put_primary_key(Ecto.Changeset.t) :: Ecto.Changeset.t
  defp put_primary_key(changeset) do
    if get_field(changeset, :drive_id) do
      changeset
    else
      pk = PK.generate([0x0004, 0x0001, 0x0001])
      put_change(changeset, :drive_id, pk)
    end
  end
end