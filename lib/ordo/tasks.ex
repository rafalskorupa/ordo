defmodule Ordo.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias Ordo.Repo

  alias Ordo.Tasks

  alias Ordo.Tasks.Projections.Task

  alias Ordo.Tasks.Projections.List

  def get_task!(actor, id) do
    Tasks.Projections.Task
    |> actor_scope(actor)
    |> Repo.get!(id)
  end

  def list_tasks(actor, list_id) do
    Tasks.Projections.Task
    |> actor_scope(actor)
    |> where(list_id: ^list_id)
    |> Repo.all()
  end

  def create_task(actor, attrs) do
    with {:ok, command} <- Tasks.Commands.CreateTask.build(actor, attrs),
         :ok <- Ordo.App.dispatch(command, consistency: :strong) do
      {:ok, get_task!(actor, command.task_id)}
    end
  end

  def complete_task(actor, %Task{} = task) do
    with {:ok, command} <- Tasks.Commands.CompleteTask.build(actor, task),
         :ok <- Ordo.App.dispatch(command, consistency: :strong) do
      {:ok, get_task!(actor, command.task_id)}
    end
  end

  def archive_task(actor, %Task{} = task) do
    with {:ok, command} <- Tasks.Commands.ArchiveTask.build(actor, task),
         :ok <- Ordo.App.dispatch(command, consistency: :strong) do
      {:ok, get_task!(actor, command.task_id)}
    end
  end

  @doc """
  Returns the list of task_lists.

  ## Examples

      iex> list_task_lists()
      [%List{}, ...]

  """
  def list_task_lists(actor) do
    List
    |> actor_scope(actor)
    |> Repo.all()
  end

  @doc """
  Gets a single list.

  Raises `Ecto.NoResultsError` if the List does not exist.

  ## Examples

      iex> get_list!(123)
      %List{}

      iex> get_list!(456)
      ** (Ecto.NoResultsError)

  """
  def get_list!(actor, id) do
    List
    |> actor_scope(actor)
    |> Repo.get!(id)
  end

  def list_exists!(actor, %{list_id: list_id}) do
    %Tasks.Commands.VerifyList{list_id: list_id, actor: actor}
    |> Ordo.App.dispatch()
  end

  @doc """
  Creates a list.

  ## Examples

      iex> create_list(%{field: value})
      {:ok, %List{}}

      iex> create_list(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_list(actor, attrs \\ %{}) do
    with {:ok, command} <- Tasks.Commands.CreateList.build(actor, attrs),
         :ok <- Ordo.App.dispatch(command, consistency: :strong) do
      {:ok, get_list!(actor, command.list_id)}
    end
  end

  @doc """
  Updates a list.

  ## Examples

      iex> update_list(list, %{field: new_value})
      {:ok, %List{}}

      iex> update_list(list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_list(actor, %List{} = list, attrs) do
    with {:ok, command} <- Tasks.Commands.UpdateList.build(actor, list, attrs),
         :ok <- Ordo.App.dispatch(command, consistency: :strong) do
      {:ok, get_list!(actor, list.id)}
    end
  end

  @doc """
  Deletes a list.

  ## Examples

      iex> delete_list(list)
      {:ok, %List{}}

      iex> delete_list(list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_list(actor, %List{} = list) do
    with {:ok, command} <- Tasks.Commands.DeleteList.build(actor, list),
         :ok <- Ordo.App.dispatch(command, consistency: :strong) do
      {:ok, list}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking list changes.

  ## Examples

      iex> change_list(list)
      %Ecto.Changeset{data: %List{}}

  """
  def create_list_changeset(command \\ %Tasks.Commands.CreateList{}, attrs) do
    command
    |> Tasks.Commands.CreateList.changeset(attrs)
  end

  def update_list_changeset(%List{} = list, attrs) do
    %Tasks.Commands.UpdateList{list_id: list.id, name: list.name}
    |> Tasks.Commands.UpdateList.changeset(attrs)
  end

  def update_list_changeset(%Tasks.Commands.UpdateList{} = command, attrs) do
    Tasks.Commands.UpdateList.changeset(command, attrs)
  end

  defp actor_scope(query, %Ordo.Actor{corpo: %{id: corpo_id}}) do
    where(query, corpo_id: ^corpo_id)
  end
end
