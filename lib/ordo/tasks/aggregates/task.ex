defmodule Ordo.Tasks.Aggregates.Task do
  defstruct [:task_id, :corpo_id, :list_id, :name, :archived, :completed, :assignees]
  @assignees_limit 5

  alias Commanded.Aggregate.Multi

  alias Ordo.Tasks.Aggregates.Task
  alias Ordo.Tasks.Commands.CreateTask
  alias Ordo.Tasks.Commands.CompleteTask
  alias Ordo.Tasks.Commands.ArchiveTask
  alias Ordo.Tasks.Commands.AssignToTask
  alias Ordo.Tasks.Commands.DeassignFromTask

  alias Ordo.Tasks.Events.TaskCreated
  alias Ordo.Tasks.Events.TaskCompleted
  alias Ordo.Tasks.Events.TaskArchived
  alias Ordo.Tasks.Events.EmployeeAssignedToTask
  alias Ordo.Tasks.Events.EmployeeDeassignedFromTask

  def create_task(%Task{}, %CreateTask{} = command) do
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

  @doc """
  Verify task exists for actor
  * Checks whether task is not archived (deleted)
  * Checks whether actor has access to task (same corpo_id)
  """
  def verify_available(%Task{archived: true}, _actor), do: {:error, :task_not_found}

  def verify_available(%Task{corpo_id: corpo_id, archived: false}, %{corpo: %{id: corpo_id}})
      when is_binary(corpo_id),
      do: :ok

  def add_assignee(%Task{assignees: assignees} = task, employee_id, actor) do
    cond do
      MapSet.member?(assignees, employee_id) ->
        {:error, :already_assigned_to_task}

      Enum.count(assignees) + 1 > @assignees_limit ->
        {:error, :too_many_assignees}

      true ->
        %EmployeeAssignedToTask{
          task_id: task.task_id,
          employee_id: employee_id,
          corpo_id: task.corpo_id,
          actor: Ordo.Actor.serialize(actor)
        }
    end
  end

  def remove_assignee(%Task{assignees: assignees} = task, employee_id, actor) do
    if MapSet.member?(assignees, employee_id) do
      %EmployeeDeassignedFromTask{
        task_id: task.task_id,
        employee_id: employee_id,
        corpo_id: task.corpo_id,
        actor: Ordo.Actor.serialize(actor)
      }
    else
      {:error, :not_assigned_to_task}
    end
  end

  def complete_task(%Task{completed: true}, _actor), do: {:error, :task_already_completed}

  def complete_task(%Task{completed: false} = task, actor) do
    %TaskCompleted{
      task_id: task.task_id,
      corpo_id: task.corpo_id,
      actor: Ordo.Actor.serialize(actor)
    }
  end

  def archive_task(%Task{archived: true}, _), do: {:error, :task_already_archived}

  def archive_task(%Task{archived: false} = task, actor) do
    %TaskArchived{
      task_id: task.task_id,
      corpo_id: task.corpo_id,
      actor: Ordo.Actor.serialize(actor)
    }
  end

  ## Execute
  def execute(%Task{} = task, %CreateTask{} = command) do
    create_task(task, command)
  end

  def execute(%Task{} = task, %CompleteTask{actor: actor}) do
    task
    |> Multi.new()
    |> Multi.execute(&verify_available(&1, actor))
    |> Multi.execute(&complete_task(&1, actor))
  end

  def execute(%Task{} = task, %ArchiveTask{
        actor: actor
      }) do
    archive_task(task, actor)
  end

  def execute(%Task{} = task, %AssignToTask{} = command) do
    %{employee_id: employee_id, actor: actor} = AssignToTask.validate!(command)

    task
    |> Multi.new()
    |> Multi.execute(&verify_available(&1, actor))
    |> Multi.execute(&add_assignee(&1, employee_id, actor))
  end

  def execute(%Task{} = task, %DeassignFromTask{} = command) do
    %{actor: actor, employee_id: employee_id} = DeassignFromTask.validate!(command)

    task
    |> Multi.new()
    |> Multi.execute(&verify_available(&1, actor))
    |> Multi.execute(&remove_assignee(&1, employee_id, actor))
  end

  def apply(%Task{}, %TaskCreated{} = ev) do
    %Task{
      task_id: ev.task_id,
      list_id: ev.task_id,
      corpo_id: ev.corpo_id,
      name: ev.name,
      assignees: MapSet.new(),
      completed: false,
      archived: false
    }
  end

  ## Apply

  def apply(%Task{} = task, %TaskCompleted{}) do
    %Task{task | completed: true}
  end

  def apply(%Task{} = task, %TaskArchived{}) do
    %Task{task | archived: true}
  end

  def apply(%Task{assignees: assignees} = task, %EmployeeAssignedToTask{} = ev) do
    %Task{task | assignees: MapSet.put(assignees, ev.employee_id)}
  end

  def apply(%Task{assignees: assignees} = task, %EmployeeDeassignedFromTask{} = ev) do
    %Task{task | assignees: MapSet.delete(assignees, ev.employee_id)}
  end
end
