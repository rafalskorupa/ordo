defmodule Ordo.Invitations.Events.InvitationCancelled do
  @derive Jason.Encoder
  @enforce_keys [:invitation_id, :corpo_id, :actor]
  defstruct [:invitation_id, :corpo_id, :actor]
end
