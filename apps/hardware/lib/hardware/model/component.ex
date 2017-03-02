defmodule Helix.Hardware.Model.Component do

  use Ecto.Schema

  alias HELL.PK
  alias Helix.Hardware.Model.ComponentSpec
  alias Helix.Hardware.Model.MotherboardSlot

  import Ecto.Changeset

  @type t :: %__MODULE__{
    component_id: PK.t,
    component_type: String.t,
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

    field :component_type, :string

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
  end

  defmodule Query do

    alias HELL.PK
    alias Helix.Hardware.Model.Component
    alias Helix.Hardware.Model.MotherboardSlot

    import Ecto.Query, only: [where: 3, select: 3, preload: 2, join: 5]

    @spec by_id(Ecto.Queryable.t, PK.t) :: Ecto.Queryable.t
    def by_id(query \\ Component, component_id),
      do: where(query, [c], c.component_id == ^component_id)

    @spec select_component_type(Ecto.Queryable.t) :: Ecto.Queryable.t
    def select_component_type(query \\ Component),
      do: select(query, [c], c.component_type)

    @spec select_component_spec(Ecto.Queryable.t) :: Ecto.Queryable.t
    def select_component_spec(query \\ Component),
      do: select(query, [c], c.component_spec)

    @spec select_component_slot(Ecto.Queryable.t) :: Ecto.Queryable.t
    def select_component_slot(query \\ Component) do
      query
      |> preload(:slot)
      |> select([c], c.slot)
    end

    @spec inner_join_linked_component(Ecto.Queryable.t) :: Ecto.Queryable.t
    def inner_join_linked_component(query \\ Component) do
      join(query, :inner, [c, ms], ms in MotherboardSlot,
        c.component_id == ms.link_component_id)
    end
  end
end