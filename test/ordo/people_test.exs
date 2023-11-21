defmodule Ordo.PeopleTest do
  use Ordo.DataCase, async: false

  import Ordo.AuthFixtures

  alias Ordo.People

  describe "create_employee/2" do
    setup do
      create_corpo_account()
    end

    test "it creates employee with employee record", %{actor: actor} do
      assert {:ok, employee} =
               People.create_employee(actor, %{first_name: "Joe", last_name: "Doe"})

      assert employee.first_name == "Joe"
      assert employee.last_name == "Doe"
      assert employee.corpo_id == actor.corpo.id
      refute employee.account_id
    end

    test "it validates name", %{actor: actor} do
      assert {:error, changeset} = People.create_employee(actor, %{first_name: "", last_name: ""})

      assert errors_on(changeset) == %{
               first_name: ["can't be blank"],
               last_name: ["can't be blank"]
             }
    end
  end

  describe "update_employee/2" do
    setup do
      create_corpo_account()
    end

    test "it updates employee first name and last name", %{actor: actor} do
      {:ok, employee} =
        People.create_employee(actor, %{first_name: "Yorinobu", last_name: "Arasaka"})

      assert {:ok, employee} =
               People.update_employee(actor, employee, %{first_name: "Joe", last_name: "Doe"})

      assert employee.first_name == "Joe"
      assert employee.last_name == "Doe"
    end

    test "it validates name", %{actor: actor} do
      {:ok, employee} =
        People.create_employee(actor, %{first_name: "Yorinobu", last_name: "Arasaka"})

      assert {:error, changeset} =
               People.update_employee(actor, employee, %{first_name: "", last_name: ""})

      assert errors_on(changeset) == %{
               first_name: ["can't be blank"],
               last_name: ["can't be blank"]
             }
    end

    test "it returns error if employee doesnt exist", %{actor: actor} do
      assert {:error, :employee_not_found} =
               People.update_employee(
                 actor,
                 %People.Projections.Employee{
                   id: Ecto.UUID.generate(),
                   first_name: "Joe",
                   last_name: "Doe"
                 },
                 %{}
               )
    end
  end

  describe "delete_employee/2" do
    setup do
      create_corpo_account()
    end

    test "it deletes employee", %{actor: actor} do
      {:ok, employee} =
        People.create_employee(actor, %{first_name: "Yorinobu", last_name: "Arasaka"})

      assert {:ok, _} =
               People.delete_employee(actor, employee)
    end

    test "it returns error if employee doesnt exist", %{actor: actor} do
      assert {:error, :employee_not_found} =
               People.delete_employee(actor, %People.Projections.Employee{
                 id: Ecto.UUID.generate()
               })
    end
  end
end
