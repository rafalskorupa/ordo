defmodule Ordo.Inventory.Commands.UpdateListing do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:listing_id, :binary_id)

    field(:name, :string)
    field(:price, :integer)

    embeds_one(:actor, Ordo.Actor)
  end

  def build(actor, listing, attrs) do
    %__MODULE__{listing_id: listing.id, actor: actor}
    |> changeset(attrs)
    |> apply_action(:build)
  end

  def changeset(command, attrs) do
    command
    |> cast(attrs, [:name, :price])
    |> validate_required([:name, :price])
  end

  def validate!(command) do
    command
    |> changeset(%{})
    |> apply_action!(:validate)
  end
end
