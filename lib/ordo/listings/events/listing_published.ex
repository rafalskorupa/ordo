defmodule Ordo.Listings.Events.ListingPublished do
  @derive Jason.Encoder
  defstruct [:listing_id, :actor]
end
