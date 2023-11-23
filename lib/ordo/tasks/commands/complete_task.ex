defmodule Ordo.Tasks.Commands.CompleteTask do
  defstruct [:task_id, :actor]

  def build(actor, %{id: task_id}) do
    {:ok, %__MODULE__{task_id: task_id, actor: actor}}
  end
end
