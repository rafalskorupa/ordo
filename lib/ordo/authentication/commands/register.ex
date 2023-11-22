defmodule Ordo.Authentication.Commands.Register do
  use Ecto.Schema
  import Ecto.Changeset
  import Ordo.Authentication.Validations

  @type t :: %__MODULE__{
          account_id: String.t(),
          email: String.t(),
          password: String.t()
        }

  embedded_schema do
    field(:account_id, :binary_id)

    field(:email, :string)
    field(:password, :string)
  end

  def build(attrs) do
    %__MODULE__{account_id: Commanded.UUID.uuid4()}
    |> changeset(attrs)
    |> apply_action(:build_command)
  end

  def validate!(command) do
    command
    |> changeset(%{})
    |> apply_action!(:validate!)
  end

  def changeset(%__MODULE__{} = command, attrs) do
    params = downcase_email(attrs)

    command
    |> cast(params, [:email, :password])
    |> validate_required([:account_id, :email, :password])
    |> validate_email()
    |> validate_password()
  end

  defp downcase_email(%{email: email} = attrs) do
    Map.put(attrs, :email, String.downcase(email))
  end

  defp downcase_email(%{"email" => email} = attrs) do
    Map.put(attrs, "email", String.downcase(email))
  end

  defp downcase_email(attrs), do: attrs
end
