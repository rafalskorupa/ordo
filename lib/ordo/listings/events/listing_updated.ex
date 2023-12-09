defmodule Ordo.Listings.Events.ListingNameChanged do
  @derive Jason.Encoder
  defstruct [:listing_id, :name, :actor]
end
