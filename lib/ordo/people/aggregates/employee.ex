defmodule Ordo.People.Aggregates.Employee do
  defstruct [:employee_id, :corpo_id, :account_id, :info, :deleted]

  alias Ordo.People.Commands.DeleteEmployee
  alias Commanded.Aggregate.Multi

  alias Ordo.People.Aggregates.Employee

  alias Ordo.People.Commands.CreateEmployee
  alias Ordo.People.Commands.CreateOwner
  alias Ordo.People.Commands.UpdateEmployee
  alias Ordo.People.Commands.DeleteEmployee

  alias Ordo.People.Events.EmployeeCreated
  alias Ordo.People.Events.EmployeeInfoChanged
  alias Ordo.People.Events.EmployeeAccountLinked
  alias Ordo.People.Events.EmployeeDeleted

  def employee_exists?(%Employee{} = employee) do
    if employee.employee_id && !employee.deleted do
      :ok
    else
      {:error, :employee_not_found}
    end
  end

  def init_employee(%Employee{employee_id: nil}, employee_id, actor) do
    struct!(EmployeeCreated, %{
      employee_id: employee_id,
      corpo_id: actor.corpo.id,
      actor: Ordo.Actor.serialize(actor)
    })
  end

  def change_employee_info(
        %Employee{employee_id: employee_id, corpo_id: corpo_id},
        changes,
        actor
      ) do
    struct!(EmployeeInfoChanged, %{
      employee_id: employee_id,
      corpo_id: corpo_id,
      changes: changes,
      actor: Ordo.Actor.serialize(actor)
    })
  end

  def link_account(%Employee{employee_id: employee_id, corpo_id: corpo_id}, account_id, actor) do
    struct!(EmployeeAccountLinked, %{
      employee_id: employee_id,
      corpo_id: corpo_id,
      account_id: account_id,
      actor: Ordo.Actor.serialize(actor)
    })
  end

  def delete_employee(%Employee{employee_id: employee_id, corpo_id: corpo_id}, actor) do
    if actor.employee.id == employee_id do
      {:error, :you_cannot_delete_yourself}
    else
      struct!(EmployeeDeleted, %{
        employee_id: employee_id,
        corpo_id: corpo_id,
        actor: Ordo.Actor.serialize(actor)
      })
    end
  end

  def execute(%Employee{} = aggregate, %CreateEmployee{} = command) do
    %{first_name: first_name, last_name: last_name, employee_id: employee_id, actor: actor} =
      CreateEmployee.validate!(command)

    aggregate
    |> Multi.new()
    |> Multi.execute(&init_employee(&1, employee_id, actor))
    |> Multi.execute(
      &change_employee_info(&1, %{first_name: first_name, last_name: last_name}, actor)
    )
  end

  def execute(%Employee{employee_id: nil, account_id: nil} = aggregate, %CreateOwner{} = command) do
    %{employee_id: employee_id, corpo_id: corpo_id, account_id: account_id} = command

    actor = %Ordo.Actor{
      employee: %{id: employee_id},
      corpo: %{id: corpo_id},
      account: %{id: account_id}
    }

    aggregate
    |> Multi.new()
    |> Multi.execute(&init_employee(&1, employee_id, actor))
    |> Multi.execute(&link_account(&1, account_id, actor))
  end

  def execute(%Employee{} = aggregate, %UpdateEmployee{} = command) do
    %{first_name: first_name, last_name: last_name, actor: actor} =
      UpdateEmployee.validate!(command)

    aggregate
    |> Multi.new()
    |> Multi.execute(&employee_exists?/1)
    |> Multi.execute(
      &change_employee_info(&1, %{first_name: first_name, last_name: last_name}, actor)
    )
  end

  def execute(%Employee{} = aggregate, %DeleteEmployee{} = command) do
    %{actor: actor} = DeleteEmployee.validate!(command)

    aggregate
    |> Multi.new()
    |> Multi.execute(&employee_exists?/1)
    |> Multi.execute(&delete_employee(&1, actor))
  end

  def apply(%Employee{} = employee, %EmployeeCreated{} = ev) do
    %Employee{employee | employee_id: ev.employee_id, corpo_id: ev.corpo_id}
  end

  def apply(%Employee{} = employee, %EmployeeAccountLinked{} = ev) do
    %Employee{employee | account_id: ev.account_id}
  end

  def apply(%Employee{} = employee, %EmployeeInfoChanged{changes: changes}) do
    info = Map.merge(employee.info || %{}, changes)

    %Employee{employee | info: info}
  end

  def apply(%Employee{} = employee, %EmployeeDeleted{}) do
    %Employee{employee | deleted: true}
  end
end
