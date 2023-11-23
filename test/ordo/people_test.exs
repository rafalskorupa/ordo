defmodule Ordo.PeopleTest do
  use Ordo.DataCase, async: false

  import Ordo.AuthFixtures

  alias Ordo.People
  alias Ordo.Invitations

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

  describe "invite_employee_by_email/3" do
    setup do
      create_corpo_account()
    end

    test "it creates mail invitation for given employee", %{actor: actor} do
      email = "joe.doe@skorupa.io"

      {:ok, employee} =
        People.create_employee(actor, %{first_name: "Yorinobu", last_name: "Arasaka"})

      assert :ok = People.invite_employee_by_email(actor, employee, %{email: email})

      assert invitation = Repo.get_by!(Invitations.Projections.Invitation, email: email)
      assert invitation.corpo_id == actor.corpo.id
      assert invitation.employee_id == employee.id
      assert invitation.email == email
    end

    test "it doesn't mail invitation for invalid email", %{actor: actor} do
      {:ok, employee} =
        People.create_employee(actor, %{first_name: "Yorinobu", last_name: "Arasaka"})

      assert {:error, changeset} =
               People.invite_employee_by_email(actor, employee, %{email: "invalid email"})

      assert errors_on(changeset) == %{
               email: ["must have the @ sign and no spaces"]
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
