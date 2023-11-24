defmodule Ordo.Tasks.Projections.Assignee do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "task_assignees" do
    belongs_to(:corpo, Ordo.Corpos.Projections.Corpo)
    belongs_to(:employee, Ordo.People.Projections.Employee)
    belongs_to(:task, Ordo.Tasks.Projections.Task)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(assignee, attrs) do
    assignee
    |> cast(attrs, [])
    |> validate_required([])
  end
end
