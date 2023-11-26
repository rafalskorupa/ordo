defmodule Ordo.Repo.Migrations.CreateEmployeeNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :notification_cursor, :bigserial
      add :read, :boolean, default: false, null: false
      add :type, :string
      add :notified_id, :binary_id
      add :notifier_id, :binary_id

      add :employee_id, :binary_id
      add :task_id, :binary_id
      add :list_id, :binary_id

      timestamps(type: :utc_datetime)
    end

    create index(:notifications, [:task_id])
    create index(:notifications, [:list_id])
    create index(:notifications, [:notified_id])
    create index(:notifications, [:notifier_id])
  end
end
