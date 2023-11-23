defmodule Ordo.Tasks.Events.TaskCreated do
  @derive Jason.Encoder
  @enforce_keys [:task_id, :corpo_id, :list_id, :name, :actor]
  defstruct [:task_id, :corpo_id, :list_id, :name, :actor]
end
