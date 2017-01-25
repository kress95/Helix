defmodule Helix.Entity.Controller.EntityAccount do

  alias Helix.Entity.Model.Entity
  alias Helix.Entity.Model.EntityAccount
  alias Helix.Entity.Repo

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
    |> EntityAccount.Query.from_entity(entity)
    |> EntityAccount.Query.select_account_id()
    |> Repo.one()
    |> case do
      nil ->
        {:error, :notfound}
      account_id ->
        {:ok, account_id}
    end
  end
end