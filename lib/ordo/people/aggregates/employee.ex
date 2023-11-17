defmodule Ordo.People.Aggregates.Employee do
  defstruct [:employee_id, :corpo_id, :account_id]

  alias Ordo.People.Aggregates.Employee
  alias Ordo.People.Commands.CreateOwner
  alias Ordo.People.Events.EmployeeCreated
  alias Ordo.People.Events.EmployeeAccountLinked

  def execute(%Employee{employee_id: nil, account_id: nil}, %CreateOwner{} = command) do
    [
      %EmployeeCreated{
        employee_id: command.employee_id,
        corpo_id: command.corpo_id,
        actor: %{
          account_id: command.account_id,
          employee_id: command.employee_id,
          corpo_id: command.corpo_id
        }
      },
      %EmployeeAccountLinked{
        employee_id: command.employee_id,
        corpo_id: command.corpo_id,
        account_id: command.account_id,
        actor: %{
          account_id: command.account_id,
          employee_id: command.employee_id,
          corpo_id: command.corpo_id
        }
      }
    ]
  end

  def apply(%Employee{} = employee, %EmployeeCreated{} = ev) do
    %Employee{employee | employee_id: ev.employee_id, corpo_id: ev.corpo_id}
  end

  def apply(%Employee{} = employee, %EmployeeAccountLinked{} = ev) do
    %Employee{employee | account_id: ev.account_id}
  end
end
