defmodule Ordo.Tasks.Events.ListNameChanged do
  @derive Jason.Encoder
  @enforce_keys [:list_id, :corpo_id, :name, :actor]
  defstruct [:list_id, :corpo_id, :name, :actor]
end
