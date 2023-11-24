defmodule Ordo.Tasks.Commands.DeassignFromTask do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:task_id, :binary_id)
    field(:employee_id, :binary_id)

    embeds_one(:actor, Ordo.Actor)
  end

  def build(actor, task, attrs) do
    %__MODULE__{task_id: task.id, actor: actor}
    |> changeset(attrs)
    |> apply_action(:build)
  end

  def changeset(command \\ %__MODULE__{}, attrs) do
    command
    |> cast(attrs, [:employee_id])
    |> validate_required([:employee_id])
  end

  def validate!(command) do
    command
    |> changeset(%{})
    |> apply_action!(:validate)
  end
end
