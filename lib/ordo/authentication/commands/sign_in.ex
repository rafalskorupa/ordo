defmodule Ordo.Authentication.Commands.SignIn do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:email)
    field(:password)
  end

  def changeset(%__MODULE__{} = command, attrs) do
    command
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
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

  def unauthenticated_error(command) do
    command
    |> changeset(%{})
    |> add_error(:base, "Invalid credentials")
  end
end
