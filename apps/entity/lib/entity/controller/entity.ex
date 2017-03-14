defmodule Helix.Entity.Controller.Entity do

  alias Helix.Entity.Model.Entity
  alias Helix.Entity.Repo

  import Ecto.Query, only: [where: 3]

  @spec create(Entity.creation_params) :: {:ok, Entity.t} | no_return
  def create(params) do
    params
    |> Entity.create_changeset()
    |> Repo.insert()
  end

  @spec fetch(Entity.id) :: Entity.t | nil
  def fetch(entity_id),
    do: Repo.get_by(Entity, entity_id: entity_id)

  @spec delete(Entity.id) :: no_return
  def delete(entity_id) do
    Entity
    |> where([s], s.entity_id == ^entity_id)
    |> Repo.delete_all()

    :ok
  end
end