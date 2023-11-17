defmodule Ordo.Authentication.Commands.SetSessionCorpo do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:session_id, :binary_id)
    field(:corpo_id, :binary_id)
  end

  def build(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> apply_action(:build)
  end

  def validate!(command) do
    command
    |> changeset(%{})
    |> apply_action!(:validate)
  end

  def changeset(%__MODULE__{} = command, attrs) do
    command
    |> cast(attrs, [:session_id, :corpo_id])
    |> validate_required([:session_id, :corpo_id])
  end
end
