defmodule Ordo.Repo.Migrations.CreateTaskAssignees do
  use Ecto.Migration

  def change do
    create table(:task_assignees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :corpo_id, references(:corpos, on_delete: :nothing, type: :binary_id)
      add :employee_id, references(:employees, on_delete: :nothing, type: :binary_id)
      add :task_id, references(:task_tasks, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:task_assignees, [:corpo_id])
    create index(:task_assignees, [:employee_id])
    create index(:task_assignees, [:task_id])
  end
end
