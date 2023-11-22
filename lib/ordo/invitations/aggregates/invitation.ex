defmodule Ordo.Invitations.Aggregates.Invitation do
  defstruct [:invitation_id, :corpo_id, :employee_id, :email, :account_id, :inviter]

  alias Ordo.Invitations.Aggregates.Invitation
  alias Ordo.People.Commands.InviteByEmail
  alias Ordo.Invitations.Commands.AcceptInvitation

  alias Ordo.Invitations.Events.InvitationCreated
  alias Ordo.Invitations.Events.InvitationAccepted

  def execute(%Invitation{invitation_id: nil}, %InviteByEmail{} = command) do
    InviteByEmail.validate!(command)

    %InvitationCreated{
      invitation_id: command.invitation_id,
      employee_id: command.employee_id,
      email: command.email,
      corpo_id: command.actor.corpo.id,
      actor: Ordo.Actor.serialize(command.actor)
    }
  end

  def execute(
        %Invitation{email: email, inviter: inviter} = invitation,
        %AcceptInvitation{actor: %{account: %{email: email}}} = command
      ) do
    :ok =
      Ordo.App.dispatch(%Ordo.People.Commands.LinkEmployee{
        employee_id: invitation.employee_id,
        corpo_id: invitation.corpo_id,
        account_id: command.actor.account_id,
        actor: inviter
      })

    %InvitationAccepted{
      invitation_id: invitation.invitation_id,
      corpo_id: invitation.corpo_id,
      employee_id: invitation.employee_id,
      account_id: command.actor.account.id,
      actor: Ordo.Actor.serialize(command.actor)
    }
  end

  def apply(%Invitation{}, %InvitationCreated{} = ev) do
    %__MODULE__{
      invitation_id: ev.invitation_id,
      email: ev.email,
      corpo_id: ev.corpo_id,
      employee_id: ev.employee_id,
      inviter: Ordo.Actor.deserialize(ev.actor)
    }
  end

  def apply(%Invitation{} = invitation, %InvitationAccepted{account_id: account_id}) do
    %__MODULE__{invitation | account_id: account_id}
  end
end
