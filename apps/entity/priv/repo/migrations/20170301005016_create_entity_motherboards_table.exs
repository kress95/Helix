defmodule Helix.Entity.Repo.Migrations.CreateEntityMotherboardsTable do
  use Ecto.Migration

  def change do
    create table(:entity_motherboards) do
      add :entity_id, references(:entities, column: :entity_id, type: :inet, on_delete: :delete_all), primary_key: true
      add :motherboard_id, :inet, primary_key: true
    end
  end
end