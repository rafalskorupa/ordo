defmodule Ordo.Invitations.Events.InvitationCreated do
  @derive Jason.Encoder
  defstruct [:invitation_id, :corpo_id, :employee_id, :email, :actor]
end

defmodule Ordo.People.Events.InvitationCreated do
  @derive Jason.Encoder
  defstruct [:invitation_id, :corpo_id, :employee_id, :email, :actor]
end
