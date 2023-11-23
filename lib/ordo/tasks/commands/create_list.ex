defmodule Ordo.Tasks.Commands.CreateList do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:list_id, :binary_id)

    field(:name, :string)

    embeds_one(:actor, Ordo.Actor)
  end

  def build(actor, attrs) do
    %__MODULE__{list_id: Ecto.UUID.generate(), actor: actor}
    |> changeset(attrs)
    |> apply_action(:build)
  end

  def changeset(command \\ %__MODULE__{}, attrs) do
    command
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def validate!(command) do
    command
    |> changeset(%{})
    |> apply_action!(:validate)
  end
end
