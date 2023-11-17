defmodule Ordo.People.Projections.Employee do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "employees" do
    field :first_name, :string
    field :last_name, :string
    field :corpo_id, :binary_id
    field :account_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(employee, attrs) do
    employee
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name])
  end
end
