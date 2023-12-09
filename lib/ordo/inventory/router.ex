defmodule Ordo.Inventory.Router do
  use Commanded.Commands.Router

  dispatch(
    [
      Ordo.Inventory.Commands.CreateListing,
      Ordo.Inventory.Commands.UpdateListing,
      Ordo.Inventory.Commands.PublishListing
    ],
    to: Ordo.Listings.Aggregates.Listing,
    identity: :listing_id
  )
end
