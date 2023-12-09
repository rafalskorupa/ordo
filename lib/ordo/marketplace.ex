defmodule Ordo.Marketplace do
  alias Ordo.Repo

  alias Ordo.Marketplace

  import Ecto.Query

  def get_listing!(listing_id) do
    Marketplace.Projections.Listing
    |> listing_scope()
    |> Repo.get!(listing_id)
  end

  def list_listings do
    Marketplace.Projections.Listing
    |> listing_scope()
    |> Repo.all()
  end

  defp listing_scope(query) do
    where(query, public: true)
  end
end
