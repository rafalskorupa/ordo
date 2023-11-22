defmodule Ordo.People.Commands.InviteByEmail do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:invitation_id, :binary_id)
    field(:corpo_id, :binary_id)
    field(:employee_id, :binary_id)

    embeds_one(:actor, Ordo.Actor)
  end

  def build(actor, attrs) do
    %__MODULE__{invitation_id: Ecto.UUID.generate(), actor: actor}
    |> change(%{corpo_id: actor.corpo.id})
    |> validate_required([:invitation_id, :corpo_id])
    |> apply_action!(:validate!)
    |> changeset(attrs)
    |> apply_action(:build)
  end

  def changeset(%__MODULE__{} = command, attrs) do
    command
    |> cast(attrs, [:employee_id])
    |> validate_required([:employee_id])
  end

  def validate!(command) do
    command
    |> changeset(%{})
    |> validate_required([:invitation_id, :corpo_id])
    |> apply_action!(:validate!)
  end
end

defmodule Ordo.People.Commands.AcceptInvitation do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:invitation_id, :binary_id)

    embeds_one(:actor, Ordo.Actor)
  end

  def build(%{corpo: nil, employee: nil} = actor, attrs) do
    %__MODULE__{invitation_id: Ecto.UUID.generate(), actor: actor}
    |> validate_required([:invitation_id])
    |> apply_action!(:validate!)
    |> changeset(attrs)
    |> apply_action(:build)
  end

  def changeset(%__MODULE__{} = command, attrs) do
    command
    |> cast(attrs, [:employee_id])
    |> validate_required([:employee_id])
  end

  def validate!(command) do
    command
    |> changeset(%{})
    |> validate_required([:invitation_id])
    |> apply_action!(:validate!)
  end
end

defmodule Ordo.People.Events.InvitationCreated do
  @derive Jason.Encoder
  defstruct [:invitation_id, :corpo_id, :employee_id, :email, :actor]
end

defmodule Ordo.People.Events.InvitationAccepted do
  @derive Jason.Encoder
  defstruct [:invitation_id, :corpo_id, :account_id]
end

defmodule Ordo.Poeple.Aggregates.Invitation do
  defstruct [:invitation_id, :corpo_id, :employee_id, :email, :account_id]

  alias Ordo.People.Aggregates.Invitation
  alias Ordo.People.Commands.InviteByEmail
  alias Ordo.People.Commands.AcceptInvitation

  alias Ordo.People.Events.InvitationCreated
  alias Ordo.People.Events.InvitationAccepted


  def execute(%__MODULE__{invitation_id: nil}, %InviteByEmail{} = command) do
    InviteByEmail.validate!(command)

    %InvitationCreated{
      invitation_id: command.invitation_id,
      employee_id: command.employee_id,
      email: command.email,
      corpo_id: command.actor.corpo.id,
      actor: Ordo.Actor.serialize(command.actor)
    }
  end

  def apply(%__MODULE__{} = invitation, %InvitationCreated{} = ev) do
    %__MODULE__{invitation_id: ev.invitation_id, email: ev.email, corpo_id: ev.corpo_id, employee_id: ev.employee_id}
  end
end
