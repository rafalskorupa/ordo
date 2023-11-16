defmodule Ordo.Authentication.Events.AccountCreated do
  @derive Jason.Encoder
  defstruct [:account_id]
end
