defmodule Ordo.People.Projections.Employee do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "employees" do
    field :first_name, :string
    field :last_name, :string

    belongs_to(:corpo, Ordo.Corpos.Projections.Corpo)
    belongs_to(:account, Ordo.Authentication.Projections.Account)
    has_many(:invitations, Ordo.Invitations.Projections.Invitation)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(employee, attrs) do
    cast(employee, attrs, [:first_name, :last_name])
  end
end
