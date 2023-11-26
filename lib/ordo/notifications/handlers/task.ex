defmodule Ordo.Notifications.Handlers.Task do
  use Commanded.Event.Handler,
    application: Ordo.App,
    name: __MODULE__,
    consistency: :eventual,
    start_from: :current

  alias Ordo.Notifications

  def handle(%module{} = event, _metadata)
      when module in [
             Ordo.Tasks.Events.EmployeeAssignedToTask,
             Ordo.Tasks.Events.EmployeeDeassignedFromTask,
             Ordo.Tasks.Events.TaskCompleted,
             Ordo.Tasks.Events.TaskArchived,
             Ordo.Tasks.Events.TaskCreated
           ] do
    Notifications.send_to_watchers(event)
  end
end
