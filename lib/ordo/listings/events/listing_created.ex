defmodule Ordo.Listings.Events.ListingCreated do
  @derive Jason.Encoder
  defstruct [:listing_id, :name, :total, :price, :corpo_id, :actor]
end
