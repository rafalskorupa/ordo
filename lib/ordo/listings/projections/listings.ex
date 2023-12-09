defmodule Ordo.Listings.Projections.Listing do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "marketplace_listings" do
    field :name, :string
    field :reserved, :integer
    field :total, :integer
    field :public, :boolean
    field :price, :integer

    belongs_to(:corpo, Ordo.Corpos.Projections.Corpo)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(listings, attrs) do
    listings
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
