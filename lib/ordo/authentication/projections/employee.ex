defmodule Ordo.Authentication.Projections.Employee do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "employees" do
    belongs_to(:corpo, Ordo.Authentication.Projections.Corpo)
    belongs_to(:account, Ordo.Authentication.Projections.Account)

    timestamps(type: :utc_datetime)
  end
end
