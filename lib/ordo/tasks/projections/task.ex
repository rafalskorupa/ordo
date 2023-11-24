defmodule Ordo.Tasks.Projections.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "task_tasks" do
    field :name, :string
    field :completed, :boolean, default: false
    field :archived, :boolean, default: false
    field :corpo_id, :binary_id
    field :list_id, :binary_id

    has_many(:assignees, Ordo.Tasks.Projections.Assignee)
    has_many(:assigned_employees, through: [:assignees, :employee])

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    cast(task, attrs, [:name, :completed, :archived])
  end
end
