defmodule Ordo.Actor do
  use Ecto.Schema
  #   import Ecto.Changeset

  embedded_schema do
    belongs_to(:account, Ordo.Authentication.Projections.Account)
    belongs_to(:employee, Ordo.People.Projections.Employee)
    belongs_to(:corpo, Ordo.Corpos.Projections.Corpo)
  end

  @type t :: %__MODULE__{
          account: %{id: String.t(), email: String.t()} | nil,
          corpo: %{id: String.t()} | nil,
          employee: %{id: String.t()} | nil
        }

  def set_corpo(%__MODULE__{} = actor, %{corpo: %{} = corpo} = employee) do
    %Ordo.Actor{actor | corpo: corpo, employee: employee}
  end

  def authenticated?(%__MODULE__{account: %{}}), do: true
  def authenticated?(_), do: false

  def has_corpo?(%__MODULE__{corpo: corpo}), do: !!corpo

  def corpo_id(%__MODULE__{corpo: nil}), do: nil
  def corpo_id(%__MODULE__{corpo: %{id: corpo_id}}), do: corpo_id

  # TODO: rework that, it doesn't make sense
  def build(nil) do
    %__MODULE__{account: nil, employee: nil, corpo: nil}
  end

  def build(%{account: account, employee: employee, corpo: corpo}) do
    %__MODULE__{account: account, employee: employee, corpo: corpo}
  end

  def build(%{account: account, corpo: corpo}) do
    %__MODULE__{account: account, corpo: corpo, employee: nil}
  end

  def build(%{account: account}) do
    %__MODULE__{account: account, corpo: nil, employee: nil}
  end

  def serialize(%__MODULE__{} = actor) do
    %{
      account_id: actor.account.id,
      corpo_id: actor.corpo.id,
      employee_id: actor.employee.id
    }
  end
end
