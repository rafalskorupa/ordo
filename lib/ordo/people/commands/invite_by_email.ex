defmodule Ordo.People.Commands.InviteByEmail do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:invitation_id, :binary_id)
    field(:corpo_id, :binary_id)
    field(:employee_id, :binary_id)

    field(:email, :string)

    embeds_one(:actor, Ordo.Actor)
  end

  def build(actor, employee, attrs) do
    attrs = downcase_email(attrs)

    %__MODULE__{invitation_id: Ecto.UUID.generate(), actor: actor}
    |> change(%{corpo_id: actor.corpo.id, employee_id: employee.id})
    |> system_validations()
    |> apply_action!(:validate!)
    |> changeset(attrs)
    |> apply_action(:build)
  end

  def changeset(%__MODULE__{} = command, attrs) do
    command
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> Ordo.Support.Validations.validate_email()
  end

  def validate!(command) do
    command
    |> changeset(%{})
    |> system_validations()
    |> apply_action!(:validate!)
  end

  def system_validations(%Ecto.Changeset{} = command) do
    command
    |> validate_required([:invitation_id, :corpo_id, :employee_id, :actor])
  end

  def system_validations(command) do
    command
    |> change(%{})
    |> system_validations()
  end

  defp downcase_email(%{email: email} = attrs) do
    Map.put(attrs, :email, String.downcase(email))
  end

  defp downcase_email(%{"email" => email} = attrs) do
    Map.put(attrs, "email", String.downcase(email))
  end

  defp downcase_email(attrs), do: attrs
end
