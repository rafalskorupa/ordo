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
end
