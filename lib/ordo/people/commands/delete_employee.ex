defmodule Ordo.People.Commands.DeleteEmployee do
  use Ecto.Schema

  embedded_schema do
    field(:employee_id, :binary_id)
    embeds_one(:actor, Ordo.Actor)
  end

  def build(actor, employee) do
    {:ok,
     %__MODULE__{
       employee_id: employee.id,
       actor: actor
     }}
  end

  def validate!(command) do
    command
  end
end
