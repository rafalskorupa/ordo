defmodule Ordo.Authentication.Projections.Corpo do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "corpos" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end
end
