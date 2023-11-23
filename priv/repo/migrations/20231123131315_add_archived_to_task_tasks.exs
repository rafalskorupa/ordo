defmodule Ordo.Repo.Migrations.AddArchivedToTaskTasks do
  use Ecto.Migration

  def change do
    alter table(:task_tasks) do
      add(:archived, :boolean, default: false, null: false)
    end
  end
end
