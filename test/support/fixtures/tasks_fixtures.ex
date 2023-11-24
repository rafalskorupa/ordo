defmodule Ordo.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ordo.Tasks` context.
  """

  @doc """
  Generate a list.
  """
  def list_fixture(actor, attrs \\ %{}) do
    attrs = Enum.into(attrs, %{name: "List Name"})

    {:ok, list} = Ordo.Tasks.create_list(actor, attrs)

    list
  end

  def create_task(%{actor: actor}) do
    %{task: task_fixture(actor)}
  end

  def archive_task(%{actor: actor, task: task}) do
    {:ok, task} = Ordo.Tasks.archive_task(actor, task)

    %{task: task}
  end

  def task_fixture(actor, attrs \\ %{}) do
    list = Map.get_lazy(attrs, :list, fn -> list_fixture(actor) end)
    attrs = Enum.into(Map.drop(attrs, [:list]), %{name: "Task Name", list_id: list.id})

    {:ok, task} = Ordo.Tasks.create_task(actor, attrs)

    task
  end

  def task_assignee_fixture(%{actor: actor, task: task}, attrs \\ %{}) do
    %{employee: employee} = Ordo.PeopleFixtures.create_employee(%{actor: actor}, attrs)

    {:ok, task} = Ordo.Tasks.assign_to_task(actor, task, %{employee_id: employee.id})
    assignee = Enum.find(task.assignees, fn assignee -> assignee.employee_id == employee.id end)

    %{employee: employee, assignee: assignee}
  end
end
