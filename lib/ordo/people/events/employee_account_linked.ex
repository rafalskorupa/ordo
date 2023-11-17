defmodule Ordo.People.Events.EmployeeAccountLinked do
  @derive Jason.Encoder
  defstruct [:employee_id, :corpo_id, :account_id, :actor]
end
