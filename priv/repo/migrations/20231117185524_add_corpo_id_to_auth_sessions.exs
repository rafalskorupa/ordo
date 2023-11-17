defmodule Ordo.Repo.Migrations.AddCorpoIdToAuthSessions do
  use Ecto.Migration

  def change do
    alter table(:auth_sessions) do
      add :corpo_id, references(:corpos, on_delete: :nilify_all, type: :binary_id), null: true

      add :employee_id, references(:employees, on_delete: :nilify_all, type: :binary_id),
        null: true
    end

    create index(:auth_sessions, [:account_id, :employee_id])
    create index(:auth_sessions, [:account_id, :corpo_id])
    create index(:auth_sessions, [:account_id, :employee_id, :corpo_id])
  end
end
