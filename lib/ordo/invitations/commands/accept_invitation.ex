defmodule Ordo.Invitations.Commands.AcceptInvitation do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:invitation_id, :binary_id)

    embeds_one(:actor, Ordo.Actor)
  end

  def build(%{corpo: nil, employee: nil} = actor, invitation) do
    %__MODULE__{actor: actor}
    |> change(%{invitation_id: invitation.id})
    |> validate_required([:invitation_id, :actor])
    |> apply_action(:build!)
    |> tap(&{:ok, &1})
  end
end
