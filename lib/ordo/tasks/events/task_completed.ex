defmodule Ordo.Tasks.Events.TaskCompleted do
  @derive Jason.Encoder
  @enforce_keys [:task_id, :corpo_id, :actor]
  defstruct [:task_id, :corpo_id, :actor]
end
