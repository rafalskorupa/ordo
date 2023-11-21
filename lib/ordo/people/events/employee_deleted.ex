defmodule Ordo.People.Events.EmployeeDeleted do
  @derive Jason.Encoder
  @enforce_keys [:employee_id, :corpo_id, :actor]
  defstruct [:employee_id, :corpo_id, :actor]
end
