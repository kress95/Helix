defmodule Helix.Entity.Controller.EntityAccountTest do

  use ExUnit.Case, async: true

  alias HELL.TestHelper.Random
  alias Helix.Entity.Controller.Entity, as: EntityController
  alias Helix.Entity.Controller.EntityAccount, as: EntityAccountController

  defp create_entity() do
    {:ok, entity} = EntityController.create(%{entity_type: "account"})
    entity
  end

  describe "linking entity and account" do
    test "creates the link" do
      entity = create_entity()
      account_id = Random.pk()

      {:ok, entity_account} = EntityAccountController.create(entity, account_id)
      {:ok, got_account_id} = EntityAccountController.find(entity)

      assert account_id == got_account_id
      assert entity_account.account_id == got_account_id
    end

    test "is a one to one relationship" do
      entity1 = create_entity()
      entity2 = create_entity()
      account_id = Random.pk()

      {:ok, _} = EntityAccountController.create(entity1, account_id)

      # entity exists
      assert {:ok, _} = EntityAccountController.find(entity1)

      # account can't be linked to another entity since it's one to one
      assert {:error, _} = EntityAccountController.create(entity2, account_id)

      # no second entity remains unlinked to any account
      assert {:error, :notfound} == EntityAccountController.find(entity2)
    end
  end

  describe "fetching account" do
    test "yields account_id when a relationship exists" do
      entity = create_entity()
      account_id = Random.pk()

      {:ok, _} = EntityAccountController.create(entity, account_id)

      # could fetch the account_id
      assert {:ok, got_account_id} = EntityAccountController.find(entity)

      # fetched value is the same as the previously linked account
      assert account_id == got_account_id
    end

    test "yields an error when no relationship exists" do
      entity = create_entity()
      assert {:error, :notfound} == EntityAccountController.find(entity)
    end
  end

  test "deleting the entity removes the linked account" do
    entity = create_entity()
    account_id = Random.pk()

    {:ok, _} = EntityAccountController.create(entity, account_id)

    # relationship exists
    assert {:ok, _} = EntityAccountController.find(entity)

    EntityController.delete(entity.entity_id)

    # can't find any relationship
    assert {:error, :notfound} = EntityAccountController.find(entity)
  end
end