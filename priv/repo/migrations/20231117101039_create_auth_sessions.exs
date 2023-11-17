defmodule Ordo.Repo.Migrations.CreateAuthSessions do
  use Ecto.Migration

  def change do
    create table(:auth_sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :account_id, references(:auth_accounts, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:auth_sessions, [:account_id])
  end
end
