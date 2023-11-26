defmodule Ordo.Notifications.Projections.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "notifications" do
    field :type, :string
    field :read, :boolean, default: false
    field :notification_cursor, :id

    belongs_to(:notified, Ordo.People.Projections.Employee)
    belongs_to(:notifier, Ordo.People.Projections.Employee)

    belongs_to(:task, Ordo.Tasks.Projections.Task)
    belongs_to(:employee, Ordo.People.Projections.Employee)
    belongs_to(:list, Ordo.Tasks.Projections.List)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notification \\ %__MODULE__{}, attrs) do
    cast(notification, attrs, [:employee_id, :task_id, :list_id])
  end
end
