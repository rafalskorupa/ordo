defmodule Ordo.People.Events.EmployeeAccountLinked do
  @derive Jason.Encoder
  @enforce_keys [:employee_id, :corpo_id, :account_id, :actor]
  defstruct [:employee_id, :corpo_id, :account_id, :actor]
end
