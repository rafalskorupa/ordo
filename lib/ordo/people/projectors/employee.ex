defmodule Ordo.People.Projectors.Employee do
  use Commanded.Projections.Ecto,
    application: Ordo.App,
    repo: Ordo.Repo,
    name: "employee-projection",
    consistency: :strong

  alias Ordo.People.Projections.Employee
  alias Ordo.People.Events.EmployeeCreated
  alias Ordo.People.Events.EmployeeAccountLinked
  alias Ordo.People.Events.EmployeeInfoChanged

  project(
    %EmployeeCreated{corpo_id: corpo_id, employee_id: employee_id},
    _metadata,
    fn multi ->
      Ecto.Multi.insert(multi, :employee, %Employee{
        id: employee_id,
        corpo_id: corpo_id
      })
    end
  )

  project(
    %EmployeeAccountLinked{employee_id: employee_id, account_id: account_id},
    _metadata,
    fn multi ->
      case Ordo.Repo.get(Employee, employee_id) do
        nil ->
          multi

        %{} = employee ->
          Ecto.Multi.update(
            multi,
            :employee,
            Ecto.Changeset.change(employee, account_id: account_id)
          )
      end
    end
  )

  project(
    %EmployeeInfoChanged{employee_id: employee_id, changes: changes},
    _metadata,
    fn multi ->
      case Ordo.Repo.get(Employee, employee_id) do
        nil ->
          multi

        %{} = employee ->
          Ecto.Multi.update(
            multi,
            :employee,
            Employee.changeset(employee, changes)
          )
      end
    end
  )
end
