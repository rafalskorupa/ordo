defmodule Ordo.TasksTest do
  use Ordo.DataCase

  alias Ordo.Tasks
  import Ordo.AuthFixtures

  describe "task_lists" do
    setup do
      create_corpo_account()
    end

    alias Ordo.Tasks.Projections.List

    import Ordo.TasksFixtures

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
