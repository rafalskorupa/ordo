defmodule Ordo.Actor do
  defstruct [:account, :corpo, :employee]

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
    %__MODULE__{}
  end

  def build(%{account: account, employee: employee, corpo: corpo}) do
    %__MODULE__{account: account, employee: employee, corpo: corpo}
  end

  def build(%{account: account, corpo: corpo}) do
    %__MODULE__{account: account, corpo: corpo}
  end

  def build(%{account: account}) do
    %__MODULE__{account: account}
  end
end
