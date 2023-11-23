defmodule Ordo.Repo.Migrations.CreateTaskTasks do
  use Ecto.Migration

  def change do
    create table(:task_tasks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :completed, :boolean, default: false, null: false
      add :corpo_id, references(:corpos, on_delete: :nothing, type: :binary_id)
      add :list_id, references(:task_lists, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:task_tasks, [:corpo_id])
    create index(:task_tasks, [:list_id])
  end
end
