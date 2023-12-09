defmodule Ordo.Repo.Migrations.CreateShopListings do
  use Ecto.Migration

  def change do
    create table(:marketplace_listings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :corpo_id, :binary_id
      add :total, :integer
      add :reserved, :integer
      add :public, :boolean, default: false
      add :price, :integer

      timestamps(type: :utc_datetime)
    end

    create index(:marketplace_listings, [:corpo_id])
  end
end
