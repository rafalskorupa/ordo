defmodule Ordo.Authentication.Commands.UpdatePassword do
  use Ecto.Schema
  import Ecto.Changeset
  import Ordo.Support.Validations

  @type t :: %__MODULE__{}

  embedded_schema do
    field(:account_id, :binary_id)
    field(:email, :string)

    field(:old_password, :string)
    field(:new_password, :string)
  end

  def validate!(command) do
    command
    |> changeset(%{})
    |> apply_action!(:validate!)
  end

  def build(%{account: %{id: account_id, email: email}}, attrs) do
    %__MODULE__{account_id: account_id, email: email}
    |> changeset(attrs)
    |> apply_action(:validate!)
  end

  def changeset(%__MODULE__{} = command, attrs) do
    command
    |> cast(attrs, [:new_password, :old_password])
    |> validate_required([:account_id, :email, :new_password, :old_password])
    |> validate_email()
    |> validate_password(:new_password)
  end
end
