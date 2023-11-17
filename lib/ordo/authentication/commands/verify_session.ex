defmodule Ordo.Authentication.Commands.VerifySession do
  defstruct [:session_id]

  def build(session_id) do
    {:ok, %__MODULE__{session_id: session_id}}
  end
end
