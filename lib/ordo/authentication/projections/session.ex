defmodule Ordo.Authentication.Projections.Session do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "auth_sessions" do
    belongs_to(:account, Ordo.Authentication.Projections.Account)
    belongs_to(:corpo, Ordo.Corpos.Projections.Corpo)
    belongs_to(:employee, Ordo.People.Projections.Employee)

    timestamps(type: :utc_datetime)
  end
end
