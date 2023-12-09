defmodule Ordo.Marketplace.Projections.Listing do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "marketplace_listings" do
    field :name, :string
    field :reserved, :integer
    field :total, :integer
    field :price, :integer
    field :public, :boolean

    timestamps(type: :utc_datetime)
  end
end
