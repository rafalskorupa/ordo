defmodule Ordo.Listings.Events.ListingPriceChanged do
  @derive Jason.Encoder
  defstruct [:listing_id, :price, :actor]
end
