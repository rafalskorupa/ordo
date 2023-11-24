defmodule Ordo.Tasks.Projectors.Assignee do
  use Commanded.Projections.Ecto,
    application: Ordo.App,
    repo: Ordo.Repo,
    name: "assignee-projection",
    consistency: :strong

  import Ecto.Query

  alias Ordo.Tasks.Projections.Assignee

  alias Ordo.Tasks.Events.EmployeeAssignedToTask
  alias Ordo.Tasks.Events.EmployeeDeassignedFromTask

  project(
    %EmployeeAssignedToTask{task_id: task_id, employee_id: employee_id, corpo_id: corpo_id},
    _metadata,
    fn multi ->
      Ecto.Multi.insert(multi, :assignee, %Assignee{
        corpo_id: corpo_id,
        task_id: task_id,
        employee_id: employee_id
      })
    end
  )

  project(
    %EmployeeDeassignedFromTask{task_id: task_id, employee_id: employee_id, corpo_id: corpo_id},
    _metadata,
    fn multi ->
      query = where(Assignee, task_id: ^task_id, employee_id: ^employee_id, corpo_id: ^corpo_id)
      Ecto.Multi.delete_all(multi, :delete_assignee, query)
    end
  )
end
