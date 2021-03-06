defmodule Helix.Hardware.Model.Component do

  use Ecto.Schema

  alias HELL.PK
  alias HELL.Constant
  alias Helix.Hardware.Model.ComponentSpec
  alias Helix.Hardware.Model.ComponentType
  alias Helix.Hardware.Model.MotherboardSlot

  import Ecto.Changeset

  @type t :: %__MODULE__{
    component_id: PK.t,
    component_type: Constant.t,
    component_spec: ComponentSpec.t,
    spec_id: String.t,
    slot: MotherboardSlot.t,
    inserted_at: NaiveDateTime.t,
    updated_at: NaiveDateTime.t
  }

  @primary_key false
  schema "components" do
    field :component_id, HELL.PK,
      primary_key: true

    # FK to ComponentType
    field :component_type, Constant

    belongs_to :component_spec, ComponentSpec,
      foreign_key: :spec_id,
      references: :spec_id,
      type: :string

    has_one :slot, MotherboardSlot,
      foreign_key: :link_component_id,
      references: :component_id

    timestamps()
  end

  @spec create_from_spec(ComponentSpec.t, PK.t) :: Ecto.Changeset.t
  def create_from_spec(cs = %ComponentSpec{}, component_id) do
    params = %{
      component_id: component_id,
      component_type: cs.component_type,
      spec_id: cs.spec_id
    }

    %__MODULE__{}
    |> cast(params, [:component_type, :spec_id, :component_id])
    |> validate_required([:component_type, :spec_id, :component_id])
    |> validate_inclusion(:component_type, ComponentType.possible_types())
  end

  defmodule Query do

    alias Helix.Hardware.Model.Component

    import Ecto.Query, only: [where: 3]

    @spec from_id_list(Ecto.Queryable.t, [HELL.PK.t]) :: Ecto.Queryable.t
    def from_id_list(query \\ Component, id_list),
      do: where(query, [c], c.component_id in ^id_list)

    @spec by_id(Ecto.Queryable.t, HELL.PK.t) :: Ecto.Queryable.t
    def by_id(query \\ Component, component_id),
      do: where(query, [c], c.component_id == ^component_id)

    @spec from_type_list(Ecto.Queryable.t, [String.t]) :: Ecto.Queryable.t
    def from_type_list(query \\ Component, type_list),
      do: where(query, [c], c.component_type in ^type_list)

    @spec by_type(Ecto.Queryable.t, String.t) :: Ecto.Queryable.t
    def by_type(query \\ Component, type),
      do: where(query, [c], c.component_type == ^type)
  end
end
