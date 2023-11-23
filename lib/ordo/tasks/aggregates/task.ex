defmodule Ordo.Tasks.Aggregates.Task do
  defstruct [:task_id, :corpo_id, :list_id, :name, :archived, :completed, :assignee]

  alias Ordo.Tasks.Aggregates.Task
  alias Ordo.Tasks.Commands.CreateTask
  alias Ordo.Tasks.Commands.CompleteTask
  alias Ordo.Tasks.Commands.ArchiveTask

  alias Ordo.Tasks.Events.TaskCreated
  alias Ordo.Tasks.Events.TaskCompleted
  alias Ordo.Tasks.Events.TaskArchived

  def execute(%Task{}, %CreateTask{} = command) do
    %{task_id: task_id, list_id: list_id, name: name, actor: actor} = command

    :ok = Ordo.Tasks.list_exists!(command.actor, %{list_id: list_id})

    %TaskCreated{
      task_id: task_id,
      list_id: list_id,
      name: name,
      corpo_id: actor.corpo.id,
      actor: Ordo.Actor.serialize(actor)
    }
  end

  def execute(%Task{task_id: task_id, corpo_id: corpo_id, completed: false}, %CompleteTask{
        task_id: task_id,
        actor: actor
      }) do
    %TaskCompleted{
      task_id: task_id,
      corpo_id: corpo_id,
      actor: Ordo.Actor.serialize(actor)
    }
  end

  def execute(%Task{task_id: task_id, corpo_id: corpo_id, completed: false}, %ArchiveTask{
        task_id: task_id,
        actor: actor
      }) do
    %TaskArchived{
      task_id: task_id,
      corpo_id: corpo_id,
      actor: Ordo.Actor.serialize(actor)
    }
  end

  def apply(%Task{}, %TaskCreated{} = ev) do
    %Task{
      task_id: ev.task_id,
      list_id: ev.task_id,
      corpo_id: ev.corpo_id,
      name: ev.name,
      assignee: nil,
      completed: false,
      archived: false
    }
  end

  def apply(%Task{} = task, %TaskCompleted{}) do
    %Task{task | completed: true}
  end

  def apply(%Task{} = task, %TaskArchived{}) do
    %Task{task | archived: true}
  end
end
