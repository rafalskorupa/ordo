defmodule Ordo.Schemas.Organisation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:organisation_id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organisations" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organisation, attrs) do
    organisation
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
