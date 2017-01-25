defmodule Helix.Entity.Repo.Migrations.RecreateEntityAccounts do
  use Ecto.Migration

  def change do
    drop table(:entity_accounts)

    create table(:entity_accounts) do
      add :entity_id, references(:entities, column: :entity_id, type: :inet, on_delete: :delete_all), primary_key: true
      add :account_id, :inet, primary_key: true
    end

    create unique_index(:entity_accounts, [:account_id])
  end
end
