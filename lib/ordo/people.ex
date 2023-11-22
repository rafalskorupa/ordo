defmodule Ordo.People do
  alias Ordo.Repo
  alias Ordo.People

  import Ecto.Query

  def list_employees(actor) do
    People.Projections.Employee
    |> employee_scope(actor)
    |> Repo.all()
    |> Repo.preload([:account, :invitations])
  end

  def get_employee!(actor, employee_id) do
    People.Projections.Employee
    |> employee_scope(actor)
    |> Repo.get!(employee_id)
    |> Repo.preload([:account, :invitations])
  end

  def create_employee(actor, attrs) do
    with {:ok, command} <- People.Commands.CreateEmployee.build(actor, attrs),
         :ok <- Ordo.App.dispatch(command, consistency: :strong) do
      {:ok, Repo.get!(People.Projections.Employee, command.employee_id)}
    end
  end

  def create_employee_changeset(command \\ %People.Commands.CreateEmployee{}, attrs) do
    People.Commands.CreateEmployee.changeset(command, attrs)
  end

  def invite_employee_by_email(actor, employee, attrs) do
    with {:ok, command} <- People.Commands.InviteByEmail.build(actor, employee, attrs) do
      Ordo.App.dispatch(command, consistency: :strong)
    end
  end

  def invite_employee_by_email_changeset(command \\ %People.Commands.InviteByEmail{}, attrs) do
    People.Commands.InviteByEmail.changeset(command, attrs)
  end

  def update_employee(actor, employee, attrs) do
    with {:ok, command} <- People.Commands.UpdateEmployee.build(actor, employee, attrs),
         :ok <- Ordo.App.dispatch(command, consistency: :strong) do
      {:ok, Repo.get!(People.Projections.Employee, command.employee_id)}
    end
  end

  def update_employee_changeset(command \\ %People.Commands.UpdateEmployee{}, attrs)

  def update_employee_changeset(%People.Projections.Employee{} = employee, attrs) do
    %People.Commands.UpdateEmployee{
      employee_id: employee.id,
      first_name: employee.first_name,
      last_name: employee.last_name
    }
    |> update_employee_changeset(attrs)
  end

  def update_employee_changeset(command, attrs) do
    People.Commands.UpdateEmployee.changeset(command, attrs)
  end

  def delete_employee(actor, employee) do
    with {:ok, command} <- People.Commands.DeleteEmployee.build(actor, employee),
         :ok <- Ordo.App.dispatch(command, consistency: :strong) do
      {:ok, employee}
    end
  end

  def employee_scope(query, %{corpo: %{id: corpo_id}}) do
    where(query, corpo_id: ^corpo_id)
  end
end
