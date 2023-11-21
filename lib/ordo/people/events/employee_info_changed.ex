defmodule Ordo.People.Events.EmployeeInfoChanged do
  @derive Jason.Encoder
  @enforce_keys [:employee_id, :corpo_id, :changes, :actor]
  defstruct [:employee_id, :corpo_id, :changes, :actor]
end
