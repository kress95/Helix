defmodule Helix.Entity.Model.EntityAccount do

  use Ecto.Schema

  alias Helix.Entity.Model.Entity

  import Ecto.Changeset

  @type t :: %__MODULE__{
    account_id: HELL.PK.t,
    entity_id: Entity.id,
    entity: Entity.t
  }

  @type creation_params :: %{account_id: HELL.PK.t, entity_id: Entity.id}

  @creation_fields ~w/account_id entity_id/a

  @primary_key false
  schema "entity_accounts" do
    field :account_id, HELL.PK,
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
    |> unique_constraint(:account_id)
  end

  defmodule Query do

    alias Helix.Entity.Model.Entity
    alias Helix.Entity.Model.EntityAccount

    import Ecto.Query, only: [where: 3, select: 3]

    @spec from_entity(Entity.t) :: Ecto.Queryable.t
    @spec from_entity(Ecto.Queryable.t, Entity.t) :: Ecto.Queryable.t
    def from_entity(query \\ EntityAccount, entity=%Entity{}),
      do: where(query, [ea], ea.entity_id == ^entity.entity_id)

    @spec from_entity_id(Entity.id) :: Ecto.Queryable.t
    @spec from_entity_id(Ecto.Queryable.t, Entity.id) :: Ecto.Queryable.t
    def from_entity_id(query \\ EntityAccount, entity_id),
      do: where(query, [ea], ea.entity_id == ^entity_id)

    @spec select_account_id() :: Ecto.Queryable.t
    @spec select_account_id(Ecto.Queryable.t) :: Ecto.Queryable.t
    def select_account_id(query \\ EntityAccount),
      do: select(query, [ea], ea.account_id)
  end
end