defmodule Ordo.Authentication.Commands.UpdatePassword do
  use Ecto.Schema
  import Ecto.Changeset
  import Ordo.Authentication.Validations

  embedded_schema do
    field(:account_id, :binary_id)
    field(:email, :string)

    field(:old_password, :string)
    field(:new_password, :string)
  end

  def validate!(command) do
    command
    |> change()
    |> changeset(%{})
    |> apply_action!(:validate!)
  end

  def build(%{account_id: account_id}, attrs) do
    %__MODULE__{account_id: account_id}
    |> changeset(attrs)
    |> apply_action(:validate!)
  end

  def changeset(%__MODULE__{} = command, attrs) do
    command
    |> cast(attrs, [:email, :new_password, :old_password])
    |> validate_required([:account_id, :email, :new_password, :old_password])
    |> validate_email()
    |> validate_password(:new_password)
  end
end
