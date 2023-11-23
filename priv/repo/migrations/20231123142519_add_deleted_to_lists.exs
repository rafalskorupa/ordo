defmodule Ordo.Repo.Migrations.AddDeletedToLists do
  use Ecto.Migration

  def change do
    alter table(:task_lists) do
      add(:soft_deleted, :boolean, default: false, null: false)
    end
  end
end
