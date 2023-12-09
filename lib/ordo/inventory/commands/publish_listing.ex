defmodule Ordo.Inventory.Commands.PublishListing do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:listing_id, :binary_id)

    embeds_one(:actor, Ordo.Actor)
  end

  def build(actor, listing) do
    %__MODULE__{listing_id: listing.id, actor: actor}
    |> changeset(%{})
    |> apply_action(:build)
  end

  def changeset(command \\ %__MODULE__{}, attrs) do
    cast(command, attrs, [])
  end

  def validate!(command) do
    command
    |> changeset(%{})
    |> apply_action!(:validate)
  end
end
