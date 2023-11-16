defmodule Ordo.Authentication.Validations do
  import Ecto.Changeset

  def validate_email(changeset, field \\ :email) do
    changeset
    |> validate_required([field])
    |> validate_format(field, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(field, max: 160)
  end

  def validate_password(changeset, field \\ :password) do
    changeset
    |> validate_required([field])
    |> validate_length(field, min: 12, max: 72)
    |> validate_length(field, max: 72, count: :bytes)
  end
end
