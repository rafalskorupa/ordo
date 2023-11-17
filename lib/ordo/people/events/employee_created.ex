defmodule Ordo.People.Events.EmployeeCreated do
  @derive Jason.Encoder
  defstruct [:employee_id, :corpo_id, :actor]
end
