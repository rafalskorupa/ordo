defmodule Ordo.Notifications.Commands.DispatchNotification do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:watcher_id, :binary_id)
    field(:notifier_id, :binary_id)

    field(:type, Ecto.Enum,
      values: [
        :assigned_to_task,
        :unassigned_from_task,
        :completed_task,
        :archived_task,
        :created_task
      ]
    )

    field(:task_id, :binary_id)
    field(:employee_id, :binary_id)
    field(:list_id, :binary_id)
  end

  def build_from_event!(watcher_id, event) do
    {actor, attrs} = Map.pop(event, "actor")
    notifier_id = actor["employee"]["id"]

    attrs
    |> Map.put("notifier_id", notifier_id)
    |> Map.put("watcher_id", watcher_id)
    |> build!()
  end

  def build!(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> apply_action(:build!)
  end

  def changeset(%__MODULE__{} = command, attrs) do
    command
    |> cast(attrs, [:watcher_id, :notifier_id, :type, :task_id, :employee_id, :list_id])
    |> validate_required([:watcher_id, :notifier_id, :type])
  end
end
