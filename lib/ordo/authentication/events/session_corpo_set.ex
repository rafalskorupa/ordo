defmodule Ordo.Authentication.Events.SessionCorpoSet do
  @derive Jason.Encoder
  defstruct [:session_id, :corpo_id]
end
