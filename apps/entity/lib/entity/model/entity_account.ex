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
end