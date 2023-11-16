defmodule Ordo.Authentication.Events.PasswordChanged do
  @derive Jason.Encoder
  defstruct [:account_id, :hashed_password]
end
