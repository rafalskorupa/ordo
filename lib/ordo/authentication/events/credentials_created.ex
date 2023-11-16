defmodule Ordo.Authentication.Events.CredentialsCreated do
  @derive Jason.Encoder
  defstruct [:account_id, :email, :hashed_password]
end
