defmodule Ordo.Tasks.Projectors.Task do
  use Commanded.Projections.Ecto,
    application: Ordo.App,
    repo: Ordo.Repo,
    name: "task-projection",
    consistency: :strong

  import Ecto.Query

  alias Ordo.Tasks.Projections.Task

  alias Ordo.Tasks.Events.TaskArchived
  alias Ordo.Tasks.Events.TaskCompleted
  alias Ordo.Tasks.Events.TaskCreated

  project(
    %TaskCreated{task_id: task_id, name: name, corpo_id: corpo_id, list_id: list_id},
    _metadata,
    fn multi ->
      Ecto.Multi.insert(multi, :list, %Task{
        id: task_id,
        corpo_id: corpo_id,
        list_id: list_id,
        name: name
      })
    end
  )

  project(
    %TaskCompleted{task_id: task_id},
    _metadata,
    fn multi ->
      Ecto.Multi.update_all(multi, :complete_task, where(Task, id: ^task_id),
        set: [completed: true]
      )
    end
  )

  project(
    %TaskArchived{task_id: task_id},
    _metadata,
    fn multi ->
      Ecto.Multi.update_all(multi, :archive_task, where(Task, id: ^task_id),
        set: [archived: true]
      )
    end
  )
end
