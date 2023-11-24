defmodule Ordo.Tasks.Events.EmployeeAssignedToTask do
  @derive Jason.Encoder
  @enforce_keys [:task_id, :employee_id, :corpo_id, :actor]
  defstruct [:task_id, :employee_id, :corpo_id, :actor]
end
