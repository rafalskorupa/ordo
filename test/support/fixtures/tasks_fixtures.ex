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

  def task_fixture(actor, attrs \\ %{}) do
    list = Map.get_lazy(attrs, :list, fn -> list_fixture(actor) end)
    attrs = Enum.into(Map.drop(attrs, [:list]), %{name: "Task Name", list_id: list.id})

    {:ok, task} = Ordo.Tasks.create_task(actor, attrs)

    task
  end
end
