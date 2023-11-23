defmodule Ordo.Tasks.Events.ListDeleted do
  @derive Jason.Encoder
  @enforce_keys [:list_id, :corpo_id, :actor]
  defstruct [:list_id, :corpo_id, :actor]
end
