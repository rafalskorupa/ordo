defmodule Ordo.Invitations.Projections.Invitation do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "invitations" do
    field :token, :string
    field :email, :string

    belongs_to(:employee, Ordo.People.Projections.Employee)
    belongs_to(:corpo, Ordo.Corpos.Projections.Corpo)

    timestamps(type: :utc_datetime)
  end
end
