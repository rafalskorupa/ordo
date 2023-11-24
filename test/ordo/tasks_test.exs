defmodule Ordo.TasksTest do
  use Ordo.DataCase

  alias Ordo.Tasks
  import Ordo.AuthFixtures
  import Ordo.TasksFixtures

  describe "get_task!/2" do
    setup [:create_corpo_account]

    test "it returns task", %{actor: actor} do
      task = task_fixture(actor)

      assert task == Tasks.get_task!(actor, task.id)
    end
  end

  describe "create_task/2" do
    setup [:create_corpo_account]

    test "it creates new task", %{actor: actor} do
      list = list_fixture(actor)

      assert {:ok, %{} = task} = Tasks.create_task(actor, %{name: "First Task", list_id: list.id})
      assert task.name == "First Task"
      assert task.list_id == list.id
      assert task.completed == false

      assert Ordo.Repo.get!(Ordo.Tasks.Projections.Task, task.id)
    end
  end

  describe "complete_task/2" do
    setup [:create_corpo_account, :create_task]

    test "it completes existing task", %{actor: actor, task: task} do
      assert {:ok, %{} = task} = Tasks.complete_task(actor, task)
      assert task.completed
    end

    test "it return task_not_found error if task is archived",
         %{actor: actor, task: task} = assigns do
      archive_task(assigns)

      assert {:error, :task_not_found} = Tasks.complete_task(actor, task)
    end

    test "it return task_not_found error if actor doesn't have access to it", %{task: task} do
      %{actor: actor} = create_corpo_account()

      assert {:error, :task_not_found} = Tasks.complete_task(actor, task)
    end
  end

  describe "archive_task/2" do
    setup [:create_corpo_account, :create_task]

    test "it archives existing task", %{actor: actor, task: task} do
      assert {:ok, %{} = task} = Tasks.archive_task(actor, task)
      assert task.archived
    end

    test "it return :task__not_found error if task is already archived",
         %{actor: actor, task: task} = assigns do
      archive_task(assigns)

      assert {:error, :task_not_found} = Tasks.archive_task(actor, task)
    end

    test "it return task_not_found error if actor doesn't have access to it", %{task: task} do
      %{actor: actor} = create_corpo_account()

      assert {:error, :task_not_found} = Tasks.archive_task(actor, task)
    end
  end

  describe "assign_to_task/3" do
    setup [:create_corpo_account, :create_task]

    test "it assign employee to task", %{actor: actor, task: task} do
      employee_id = actor.employee.id

      assert {:ok, %{} = task} = Tasks.assign_to_task(actor, task, %{employee_id: employee_id})
      assert [%{id: ^employee_id}] = task.assigned_employees
    end

    test "it returns too many assignees error", %{actor: actor} do
      task = task_fixture(actor)
      task_assignee_fixture(%{actor: actor, task: task})
      task_assignee_fixture(%{actor: actor, task: task})
      task_assignee_fixture(%{actor: actor, task: task})

      assert {:error, :too_many_assignees} =
               Tasks.assign_to_task(actor, task, %{employee_id: actor.employee.id})
    end

    test "it returns already assigned error", %{actor: actor} do
      task = task_fixture(actor)
      %{employee: %{id: employee_id}} = task_assignee_fixture(%{actor: actor, task: task})

      assert {:error, :already_assigned_to_task} =
               Tasks.assign_to_task(actor, task, %{employee_id: employee_id})
    end
  end

  describe "deassign_from_task/3" do
    setup [:create_corpo_account, :create_task]

    test "it deassign employee from task", %{actor: actor, task: task} do
      %{employee: %{id: employee_id}} = task_assignee_fixture(%{actor: actor, task: task})

      assert {:ok, %{} = task} =
               Tasks.deassign_from_task(actor, task, %{employee_id: employee_id})

      assert task.assignees == []
    end

    test "it returns not assigned error", %{actor: actor, task: task} do
      employee_id = Ecto.UUID.generate()

      assert {:error, :not_assigned_to_task} =
               Tasks.deassign_from_task(actor, task, %{employee_id: employee_id})
    end
  end

  describe "verify_list!/2" do
    setup [:create_corpo_account]

    test "returns :ok if list exists", %{actor: actor} do
      list = list_fixture(actor)

      assert :ok == Tasks.verify_list!(actor, %{list_id: list.id})
    end

    test "returns list_not_found error if list doesn't exists", %{actor: actor} do
      assert {:error, :list_not_found} ==
               Tasks.verify_list!(actor, %{list_id: Ecto.UUID.generate()})
    end
  end

  describe "task_lists" do
    setup do
      create_corpo_account()
    end

    alias Ordo.Tasks.Projections.List

    @invalid_attrs %{name: nil}

    test "list_task_lists/1 returns all task_lists", %{actor: actor} do
      list = list_fixture(actor)
      assert Tasks.list_task_lists(actor) == [list]
    end

    test "get_list!/2 returns the list with given id", %{actor: actor} do
      list = list_fixture(actor)
      assert Tasks.get_list!(actor, list.id) == list
    end

    test "create_list/2 with valid data creates a list", %{actor: actor} do
      valid_attrs = %{name: "some name"}

      assert {:ok, %List{} = list} = Tasks.create_list(actor, valid_attrs)
      assert list.name == "some name"
    end

    test "create_list/2 with invalid data returns error changeset", %{actor: actor} do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_list(actor, @invalid_attrs)
    end

    test "update_list/3 with valid data updates the list", %{actor: actor} do
      list = list_fixture(actor)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %List{} = list} = Tasks.update_list(actor, list, update_attrs)
      assert list.name == "some updated name"
    end

    test "update_list/3 with invalid data returns error changeset", %{actor: actor} do
      list = list_fixture(actor)
      assert {:error, %Ecto.Changeset{}} = Tasks.update_list(actor, list, @invalid_attrs)
      assert list == Tasks.get_list!(actor, list.id)
    end

    test "delete_list/2 deletes the list", %{actor: actor} do
      list = list_fixture(actor)
      assert {:ok, %List{}} = Tasks.delete_list(actor, list)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_list!(actor, list.id) end
    end
  end
end
