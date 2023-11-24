defmodule Ordo.Actor do
  use Ecto.Schema
  #   import Ecto.Changeset

  embedded_schema do
    belongs_to(:account, Ordo.Authentication.Projections.Account)
    belongs_to(:employee, Ordo.Authentication.Projections.Employee)
    belongs_to(:corpo, Ordo.Corpos.Projections.Corpo)
  end

  @type t :: %__MODULE__{}

  @spec set_corpo(t(), Ordo.Authentication.Projections.Employee.t()) :: t()
  def set_corpo(%__MODULE__{} = actor, %{corpo: %{} = corpo} = employee) do
    %Ordo.Actor{actor | corpo: corpo, employee: employee}
  end

  def authenticated?(%__MODULE__{account: %{}}), do: true
  def authenticated?(_), do: false

  def has_corpo?(%__MODULE__{corpo: corpo}), do: !!corpo

  def build(nil) do
    %__MODULE__{account: nil, employee: nil, corpo: nil}
  end

  def build(%{account: account, employee: employee, corpo: corpo}) do
    %__MODULE__{
      account_id: account.id,
      account: account,
      employee_id: employee.id,
      employee: employee,
      corpo_id: corpo.id,
      corpo: corpo
    }
  end

  def build(%{account: account}) do
    %__MODULE__{account_id: account.id, account: account, corpo: nil, employee: nil}
  end

  def deserialize(%{account_id: account_id, corpo_id: corpo_id, employee_id: employee_id}) do
    %Ordo.Actor{
      account: %{id: account_id},
      corpo: %{id: corpo_id},
      employee: %{id: employee_id}
    }
  end

  def serialize(%__MODULE__{} = actor) do
    %{
      account_id: account_id(actor),
      corpo_id: corpo_id(actor),
      employee_id: employee_id(actor)
    }
  end

  def account_id(%{account: %{id: account_id}}) do
    account_id
  end

  def account_id(_) do
    nil
  end

  def corpo_id(%{corpo: %{id: corpo_id}}) do
    corpo_id
  end

  def corpo_id(_) do
    nil
  end

  def employee_id(%{employee: %{id: employee_id}}) do
    employee_id
  end

  def employee_id(_) do
    nil
  end
end
