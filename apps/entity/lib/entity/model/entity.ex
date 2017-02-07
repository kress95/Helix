defmodule Helix.Entity.Model.Entity do

  use Ecto.Schema

  alias HELL.PK
  alias Helix.Entity.Model.EntityServer
  alias Helix.Entity.Model.EntityType

  import Ecto.Changeset

  @type id :: PK.t
  @type t :: %__MODULE__{
    entity_id: id,
    servers: [EntityServer.t],
    type: EntityType.t,
    entity_type: String.t,
    inserted_at: NaiveDateTime.t,
    updated_at: NaiveDateTime.t
  }

  @type creation_params :: %{
    entity_type: EntityType.name}

  @creation_fields ~w/entity_type entity_id/a

  @primary_key false
  schema "entities" do
    field :entity_id, PK,
      primary_key: true

    has_many :servers, EntityServer,
      foreign_key: :entity_id,
      references: :entity_id
    belongs_to :type, EntityType,
      foreign_key: :entity_type,
      references: :entity_type,
      type: :string

    timestamps()
  end

  @spec create_changeset(creation_params) :: Ecto.Changeset.t
  def create_changeset(params) do
    %__MODULE__{}
    |> cast(params, @creation_fields)
    |> validate_required(@creation_fields)
  end


  defmodule Query do

    alias HELL.PK
    alias Helix.Entity.Model.Entity

    import Ecto.Query, only: [where: 3, select: 3]

    @spec by_id(Ecto.Queryable.t, PK.t) :: Ecto.Queryable.t
    def by_id(query \\ Entity, entity_id),
      do: where(query, [c], c.entity_id == ^entity_id)

    @spec select_entity_type(Ecto.Queryable.t) :: Ecto.Queryable.t
    def select_entity_type(query \\ Entity),
      do: select(query, [c], c.entity_type)
  end
end