defmodule HELM.Software.Model.Module do

  use Ecto.Schema

  alias HELL.PK
  alias HELM.Software.Model.ModuleRole, as: MdlModuleRole, warn: false
  alias HELM.Software.Model.File, as: MdlFile, warn: false
  import Ecto.Changeset

  @type t :: %__MODULE__{
    module_version: non_neg_integer,
    file: MdlFile.t,
    file_id: PK.t,
    role: MdlModuleRole.t,
    module_role: String.t,
    inserted_at: Ecto.DateTime.t,
    updated_at: Ecto.DateTime.t
  }

  @type creation_params :: %{
    file_id: PK.t,
    module_role: String.t,
    module_version: non_neg_integer
  }
  @type update_params :: %{module_version: non_neg_integer}

  @creation_fields ~w/file_id module_role module_version/a
  @update_fields ~w/module_version/a

  @primary_key false
  schema "modules" do
    belongs_to :file, MdlFile,
      foreign_key: :file_id,
      references: :file_id,
      type: EctoNetwork.INET,
      primary_key: true
    belongs_to :role, MdlModuleRole,
      foreign_key: :module_role,
      references: :module_role,
      type: :string,
      primary_key: true

    field :module_version, :integer

    timestamps
  end

  @spec create_changeset(creation_params) :: Ecto.Changeset.t
  def create_changeset(params) do
    %__MODULE__{}
    |> cast(params, @creation_fields)
    |> validate_required([:file_id, :module_role, :module_version])
    |> generic_validations()
  end

  @spec update_changeset(t | Ecto.Changeset.t, update_params) :: Ecto.Changeset.t
  def update_changeset(schema, params) do
    schema
    |> cast(params, @update_fields)
    |> generic_validations()
  end

  @spec generic_validations(Ecto.Changeset.t) :: Ecto.Changeset.t
  def generic_validations(changeset) do
    changeset
    |> validate_number(:module_version, greater_than: 0)
  end
end