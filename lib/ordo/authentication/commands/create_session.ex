defmodule Ordo.Authentication.Commands.CreateSession do
  defstruct [:session_id, :actor]

  def build(actor) do
    {:ok,
     %__MODULE__{
       actor: actor,
       session_id: Commanded.UUID.uuid4()
     }}
  end
end
