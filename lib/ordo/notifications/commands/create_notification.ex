defmodule Ordo.Notifications.Commands.CreateEmployeeNotification do
  defstruct [:notification_id, :notified_id, :notifier_id, :type, :payload]

  def build!(notified_id, event) do
    %__MODULE__{
      notification_id: Ecto.UUID.generate(),
      notified_id: notified_id,
      notifier_id: event.actor.employee_id,
      type: type(event),
      payload: Map.take(event, [:task_id, :list_id, :corpo_id, :employee_id])
    }
  end

  defp type(%Ordo.Tasks.Events.EmployeeAssignedToTask{}), do: "task.assigned"
  defp type(%Ordo.Tasks.Events.EmployeeDeassignedFromTask{}), do: "task.unassigned"
  defp type(%Ordo.Tasks.Events.TaskCompleted{}), do: "task.completed"
  defp type(%Ordo.Tasks.Events.TaskArchived{}), do: "task.archived"
  defp type(%Ordo.Tasks.Events.TaskCreated{}), do: "task.created"
end
