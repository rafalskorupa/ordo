defmodule Ordo.Repo.Migrations.CreateOrganisations do
  use Ecto.Migration

  def change do
    create table(:organisations, primary_key: false) do
      add :organisation_id, :binary_id, primary_key: true
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
