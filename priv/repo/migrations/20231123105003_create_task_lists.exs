defmodule Ordo.Repo.Migrations.CreateTaskLists do
  use Ecto.Migration

  def change do
    create table(:task_lists, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :corpo_id, references(:corpos, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:task_lists, [:corpo_id])
  end
end
