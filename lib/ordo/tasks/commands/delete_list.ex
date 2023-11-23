defmodule Ordo.Tasks.Commands.DeleteList do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:list_id, :binary_id)

    embeds_one(:actor, Ordo.Actor)
  end

  def build(actor, list) do
    %__MODULE__{list_id: list.id, actor: actor}
    |> changeset(%{})
    |> apply_action(:build)
  end

  def changeset(command \\ %__MODULE__{}, attrs) do
    command
    |> cast(attrs, [])
    |> validate_required([])
  end

  def validate!(command) do
    command
    |> changeset(%{})
    |> apply_action!(:validate)
  end
end
