defmodule Ordo.Authentication.Events.SessionCreated do
  @derive Jason.Encoder
  defstruct [:session_id, :account_id]
end
