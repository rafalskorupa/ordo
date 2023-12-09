defmodule Ordo.Listings.Projectors.List do
  use Commanded.Projections.Ecto,
    application: Ordo.App,
    repo: Ordo.Repo,
    name: __MODULE__,
    consistency: :strong

  import Ecto.Query

  alias Ordo.Listings.Projections.Listing

  alias Ordo.Listings.Events.ListingCreated
  alias Ordo.Listings.Events.ListingNameChanged
  alias Ordo.Listings.Events.ListingPriceChanged
  alias Ordo.Listings.Events.ListingPublished

  project(
    %ListingCreated{
      listing_id: listing_id,
      corpo_id: corpo_id,
      name: name,
      price: price,
      total: total
    },
    _metadata,
    fn multi ->
      Ecto.Multi.insert(multi, :listing, %Listing{
        id: listing_id,
        corpo_id: corpo_id,
        name: name,
        total: total,
        price: price,
        reserved: 0,
        public: false
      })
    end
  )

  project(
    %ListingPublished{listing_id: listing_id},
    _metadata,
    fn multi ->
      Ecto.Multi.update_all(multi, :listing, where(Listing, id: ^listing_id), set: [public: true])
    end
  )

  project(
    %ListingNameChanged{listing_id: listing_id, name: name},
    _metadata,
    fn multi ->
      Ecto.Multi.update_all(multi, :listing, where(Listing, id: ^listing_id), set: [name: name])
    end
  )

  project(
    %ListingPriceChanged{listing_id: listing_id, price: price},
    _metadata,
    fn multi ->
      Ecto.Multi.update_all(multi, :listing, where(Listing, id: ^listing_id), set: [price: price])
    end
  )
end
