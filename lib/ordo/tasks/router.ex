defmodule Ordo.Tasks.Router do
  use Commanded.Commands.Router

  dispatch(
    [
      Ordo.Tasks.Commands.VerifyList,
      Ordo.Tasks.Commands.CreateList,
      Ordo.Tasks.Commands.UpdateList,
      Ordo.Tasks.Commands.DeleteList
    ],
    to: Ordo.Tasks.Aggregates.List,
    identity: :list_id
  )

  dispatch(
    [
      Ordo.Tasks.Commands.CreateTask,
      Ordo.Tasks.Commands.ArchiveTask,
      Ordo.Tasks.Commands.CompleteTask,
      Ordo.Tasks.Commands.AssignToTask,
      Ordo.Tasks.Commands.DeassignFromTask
    ],
    to: Ordo.Tasks.Aggregates.Task,
    identity: :task_id
  )
end
