defmodule Ordo.Repo.Migrations.CreateInvitations do
  use Ecto.Migration

  def change do
    create table(:invitations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string
      add :token, :string
      add :employee_id, references(:employees, on_delete: :nothing, type: :binary_id)
      add :corpo_id, references(:corpos, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:invitations, [:employee_id])
    create index(:invitations, [:corpo_id])
    create index(:invitations, [:email])
  end
end
