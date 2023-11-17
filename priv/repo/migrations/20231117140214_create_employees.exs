defmodule Ordo.Repo.Migrations.CreateEmployees do
  use Ecto.Migration

  def change do
    create table(:employees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :first_name, :string
      add :last_name, :string

      add :corpo_id, :binary_id

      add :account_id, :binary_id,
        null: true

      timestamps(type: :utc_datetime)
    end

    create index(:employees, [:corpo_id])
    create index(:employees, [:account_id])
  end
end
