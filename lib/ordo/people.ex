defmodule Ordo.People do
  alias Ordo.Repo
  alias Ordo.People

  import Ecto.Query

  def list_employees(actor) do
    People.Projections.Employee
    |> employee_scope(actor)
    |> Repo.all()
  end

  def get_employee!(actor, employee_id) do
    People.Projections.Employee
    |> employee_scope(actor)
    |> Repo.get!(employee_id)
  end

  def employee_scope(query, %{corpo: %{id: corpo_id}}) do
    where(query, corpo_id: ^corpo_id)
  end
end
