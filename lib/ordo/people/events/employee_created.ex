defmodule Ordo.People.Events.EmployeeCreated do
  @derive Jason.Encoder
  @enforce_keys [:employee_id, :corpo_id, :actor]
  defstruct [:employee_id, :corpo_id, :actor]
end
