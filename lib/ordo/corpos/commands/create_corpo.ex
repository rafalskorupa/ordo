defmodule Ordo.Corpos.Commands.CreateCorpo do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:corpo_id, :binary_id)
    field(:name)

    field(:account_id, :binary_id)
  end

  def build(actor, attrs) do
    %__MODULE__{account_id: actor.account.id, corpo_id: Ecto.UUID.generate()}
    |> changeset(attrs)
    |> apply_action(:build)
  end

  def validate!(command) do
    command
    |> changeset(%{})
    |> validate_required([:corpo_id, :account_id])
    |> apply_action!(:validate)
  end

  def changeset(%__MODULE__{} = command, attrs) do
    command
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
