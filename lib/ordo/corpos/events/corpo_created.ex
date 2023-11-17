defmodule Ordo.Corpos.Events.CorpoCreated do
  @derive Jason.Encoder
  defstruct [:corpo_id, :name, :account_id]
end
