defmodule Ordo.Authentication.Projections.Employee do
  use Ecto.Schema

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "employees" do
    field(:first_name)
    field(:last_name)

    belongs_to(:corpo, Ordo.Authentication.Projections.Corpo)
    belongs_to(:account, Ordo.Authentication.Projections.Account)

    timestamps(type: :utc_datetime)
  end
end
