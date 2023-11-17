defmodule Ordo.Authentication.Projections.Session do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "auth_sessions" do
    field :account_id, :binary_id

    timestamps(type: :utc_datetime)
  end
end
