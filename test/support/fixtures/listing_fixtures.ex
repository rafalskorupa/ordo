defmodule Ordo.ListingsFixtures do
  alias Ordo.Inventory

  def create_listing(%{actor: actor}, attrs \\ %{}) do
    create_params = valid_listing_attribute(attrs)

    {:ok, listing} = Inventory.create_listing(actor, create_params)

    {:ok, listing} =
      case Map.get(attrs, :public, false) do
        true ->
          Inventory.publish_listing(actor, listing)

        false ->
          {:ok, listing}
      end

    %{listing: listing}
  end

  def create_public_listing(%{actor: actor}, attrs \\ %{}) do
    create_params = valid_listing_attribute(attrs)

    {:ok, listing} = Inventory.create_listing(actor, create_params)
    {:ok, listing} = Inventory.publish_listing(actor, listing)

    %{listing: listing}
  end

  def valid_listing_attribute(attrs \\ %{}) do
    attrs
    |> Map.take([:name, :total])
    |> Enum.into(%{
      name: "Listing name",
      total: 20,
      price: 2999
    })
  end
end
