defmodule Ordo.Inventory.Commands.CreateListing do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:listing_id, :binary_id)

    field(:name, :string)
    field(:price, :integer)
    field(:total, :integer)

    embeds_one(:actor, Ordo.Actor)
  end

  def build(actor, attrs) do
    %__MODULE__{listing_id: Ecto.UUID.generate(), actor: actor}
    |> changeset(attrs)
    |> apply_action(:build)
  end

  def changeset(command \\ %__MODULE__{}, attrs) do
    command
    |> cast(attrs, [:total, :name, :price])
    |> validate_required([:total, :name, :price])
  end

  def validate!(command) do
    command
    |> changeset(%{})
    |> apply_action!(:validate)
  end
end
