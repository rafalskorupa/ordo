defmodule Ordo.Invitations.Projectors.Invitation do
  use Commanded.Projections.Ecto,
    application: Ordo.App,
    repo: Ordo.Repo,
    name: "Invitation-projection",
    consistency: :strong

  import Ecto.Query

  alias Ordo.Invitations.Projections.Invitation
  alias Ordo.Invitations.Events.InvitationCreated
  alias Ordo.Invitations.Events.InvitationAccepted

  project(
    %InvitationCreated{
      corpo_id: corpo_id,
      invitation_id: invitation_id,
      employee_id: employee_id,
      email: email
    },
    _metadata,
    fn multi ->
      Ecto.Multi.insert(multi, :invitation, %Invitation{
        id: invitation_id,
        corpo_id: corpo_id,
        employee_id: employee_id,
        email: email
      })
    end
  )

  project(
    %InvitationAccepted{invitation_id: invitation_id},
    _metadata,
    fn multi ->
      query = where(Invitation, id: ^invitation_id)
      Ecto.Multi.delete_all(multi, :invitation, query)
    end
  )
end
