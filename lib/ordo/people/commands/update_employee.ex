defmodule Ordo.People.Commands.UpdateEmployee do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:employee_id, :binary_id)

    field(:first_name, :string)
    field(:last_name, :string)

    embeds_one(:actor, Ordo.Actor)
  end

  def build(actor, employee, attrs) do
    %__MODULE__{
      employee_id: employee.id,
      first_name: employee.first_name,
      last_name: employee.last_name,
      actor: actor
    }
    |> changeset(attrs)
    |> apply_action(:build)
  end

  def changeset(command \\ %__MODULE__{}, attrs)

  def changeset(command, attrs) do
    command
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name])
  end

  def validate!(command) do
    command
    |> changeset(%{})
    |> apply_action!(:validate)
  end
end
