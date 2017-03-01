defmodule Helix.Entity.Controller.EntityMotherboard do

  alias Helix.Entity.Model.Entity
  alias Helix.Entity.Model.EntityMotherboard
  alias Helix.Entity.Repo

  @spec create(Entity.id, HELL.PK.t) ::
    {:ok, EntityMotherboard.t}
    | {:error, Ecto.Changeset.t}
  def create(entity_id, motherboard_id) do
    %{entity_id: entity_id, motherboard_id: motherboard_id}
    |> EntityMotherboard.create_changeset()
    |> Repo.insert()
  end

  @spec find(Entity.t | Entity.id) :: [EntityMotherboard.t]
  def find(entity_or_entity_id) do
    entity_or_entity_id
    |> EntityMotherboard.Query.from_entity()
    |> Repo.all()
  end

  @spec delete(Entity.t | Entity.id, HELL.PK.t) :: no_return
  def delete(entity_or_entity_id, motherboard_id) do
    entity_or_entity_id
    |> EntityMotherboard.Query.from_entity()
    |> EntityMotherboard.Query.by_motherboard_id(motherboard_id)
    |> Repo.delete_all()

    :ok
  end
end