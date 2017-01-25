defmodule Helix.Entity.Controller.EntityAccount do

  alias Helix.Entity.Model.Entity
  alias Helix.Entity.Model.EntityAccount
  alias Helix.Entity.Repo

  import Ecto.Query, only: [where: 3, select: 3]

  @spec create(Entity.t, HELL.PK.t) ::
    {:ok, EntityAccount.t}
    | {:error, Ecto.Changeset.t}
  def create(entity, account_id) do
    %{entity_id: entity.entity_id, account_id: account_id}
    |> EntityAccount.create_changeset()
    |> Repo.insert()
  end

  @spec find(Entity.t) :: {:ok, HELL.PK.t} | {:error, :notfound}
  def find(entity) do
    EntityAccount
    |> where([a], a.entity_id == ^entity.entity_id)
    |> select([a], a.account_id)
    |> Repo.one()
    |> case do
      nil ->
        {:error, :notfound}
      account_id ->
        {:ok, account_id}
    end
  end

  @spec delete(Entity.t, HELL.PK.t) :: no_return
  def delete(entity, account_id) do
    EntityAccount
    |> where([a], a.entity_id == ^entity.entity_id)
    |> where([a], a.account_id == ^account_id)
    |> Repo.delete_all()

    :ok
  end
end