defmodule Ordo.Tasks.Projections.List do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "task_lists" do
    field :name, :string
    field :soft_deleted, :boolean
    belongs_to(:corpo, Ordo.Corpos.Projections.Corpo)

    has_many(:tasks, Ordo.Tasks.Projections.Task)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:name, :corpo_id])
    |> validate_required([:name])
  end
end
