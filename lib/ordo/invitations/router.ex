defmodule Ordo.Invitations.Router do
  use Commanded.Commands.Router

  dispatch(
    [
      Ordo.People.Commands.InviteByEmail,
      Ordo.Invitations.Commands.AcceptInvitation
    ],
    to: Ordo.Invitations.Aggregates.Invitation,
    identity: :invitation_id
  )
end
