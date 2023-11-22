defmodule Ordo.Invitations do
  alias Ordo.Repo

  import Ecto.Query

  alias Ordo.Invitations.Projections.Invitation

  def list_invitations(%Ordo.Actor{account: %{email: email}}) do
    Invitation
    |> where(email: ^email)
    |> Repo.all()
    |> Repo.preload([:corpo])
  end

  def get_invitation(actor, invitation_id) do
    email = actor.account.email

    Invitation
    |> where(email: ^email)
    |> Repo.get(invitation_id)
    |> Repo.preload([:corpo])
  end

  def accept_invitation(actor, invitation) do
    with {:ok, command} <- Ordo.Invitations.Commands.AcceptInvitation.build(actor, invitation) do
      Ordo.App.dispatch(command, consistency: :strong)
    end
  end

  def cancel_invitation(actor, invitation) do
    with {:ok, command} <- Ordo.Invitations.Commands.CancelInvitation.build(actor, invitation) do
      Ordo.App.dispatch(command, consistency: :strong)
    end
  end
end
