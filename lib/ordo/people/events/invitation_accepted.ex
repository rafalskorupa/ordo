defmodule Ordo.Invitations.Events.InvitationAccepted do
  @derive Jason.Encoder
  @enforce_keys [:invitation_id, :employee_id, :corpo_id, :account_id, :actor]
  defstruct [:invitation_id, :employee_id, :corpo_id, :account_id, :actor]
end
