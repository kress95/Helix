defmodule Helix.Entity.Model.EntityMotherboard do

  use Ecto.Schema

  alias Helix.Entity.Model.Entity

  import Ecto.Changeset

  @type t :: %__MODULE__{
    motherboard_id: HELL.PK.t,
    entity_id: Entity.id,
    entity: Entity.t
  }

  @type creation_params :: %{motherboard_id: HELL.PK.t, entity_id: Entity.id}

  @creation_fields ~w/motherboard_id entity_id/a

  @primary_key false
  schema "entity_motherboards" do
    field :motherboard_id, HELL.PK,
      primary_key: true
    belongs_to :entity, Entity,
      foreign_key: :entity_id,
      references: :entity_id,
      type: HELL.PK,
      primary_key: true
  end

  @spec create_changeset(creation_params) :: Ecto.Changeset.t
  def create_changeset(params) do
    %__MODULE__{}
    |> cast(params, @creation_fields)
    |> validate_required(@creation_fields)
  end

  defmodule Query do

    alias Helix.Entity.Model.Entity
    alias Helix.Entity.Model.EntityMotherboard

    import Ecto.Query, only: [where: 3]

    @spec from_entity(Ecto.Queryable.t, Entity.t | Entity.id) ::
      Ecto.Queryable.t
    def from_entity(query \\ EntityMotherboard, entity_or_entity_id)
    def from_entity(query, entity = %Entity{}),
      do: from_entity(query, entity.entity_id)
    def from_entity(query, entity_id),
      do: where(query, [em], em.entity_id == ^entity_id)

    @spec by_motherboard_id(Ecto.Queryable.t, HELL.PK.t) ::
      Ecto.Queryable.t
    def by_motherboard_id(query \\ EntityMotherboard, motherboard_id),
      do: where(query, [em], em.motherboard_id == ^motherboard_id)
  end
end