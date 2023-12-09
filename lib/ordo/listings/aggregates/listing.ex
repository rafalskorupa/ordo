defmodule Ordo.Listings.Aggregates.Listing do
  defstruct [:listing_id, :name, :total, :price, :reserved, :public, :corpo_id]

  alias Commanded.Aggregate.Multi

  alias Ordo.Listings.Aggregates.Listing

  alias Ordo.Inventory.Commands.CreateListing
  alias Ordo.Inventory.Commands.PublishListing
  alias Ordo.Inventory.Commands.UpdateListing

  alias Ordo.Listings.Events.ListingCreated
  alias Ordo.Listings.Events.ListingNameChanged
  alias Ordo.Listings.Events.ListingPriceChanged
  alias Ordo.Listings.Events.ListingPublished

  def listing_available(%Listing{corpo_id: corpo_id}, %{corpo: %{id: corpo_id}}), do: :ok
  def listing_available(_, _), do: {:error, :listing_not_found}

  def publish_listing(%Listing{public: true}, _actor) do
    {:error, :listing_already_published}
  end

  def publish_listing(%Listing{listing_id: listing_id, public: false}, actor) do
    %ListingPublished{
      listing_id: listing_id,
      actor: Ordo.Actor.serialize(actor)
    }
  end

  def update_listing_name(%Listing{name: name}, %{name: name}, _actor) do
    :ok
  end

  def update_listing_name(%Listing{listing_id: listing_id}, %{name: name}, actor) do
    %ListingNameChanged{
      listing_id: listing_id,
      name: name,
      actor: Ordo.Actor.serialize(actor)
    }
  end

  def update_listing_price(%Listing{price: price}, %{price: price}, _actor) do
    :ok
  end

  def update_listing_price(%Listing{listing_id: listing_id}, %{price: price}, actor) do
    %ListingPriceChanged{
      listing_id: listing_id,
      price: price,
      actor: Ordo.Actor.serialize(actor)
    }
  end

  # Execute

  def execute(%Listing{}, %CreateListing{} = command) do
    %{listing_id: listing_id, price: price, name: name, total: total, actor: actor} =
      CreateListing.validate!(command)

    %ListingCreated{
      listing_id: listing_id,
      corpo_id: actor.corpo.id,
      total: total,
      price: price,
      name: name,
      actor: Ordo.Actor.serialize(actor)
    }
  end

  def execute(%Listing{} = listing, %UpdateListing{} = command) do
    %{actor: actor} = UpdateListing.validate!(command)

    listing
    |> Multi.new()
    |> Multi.execute(&listing_available(&1, actor))
    |> Multi.execute(&update_listing_name(&1, command, actor))
    |> Multi.execute(&update_listing_price(&1, command, actor))
  end

  def execute(%Listing{} = listing, %PublishListing{} = command) do
    %{actor: actor} = PublishListing.validate!(command)

    listing
    |> Multi.new()
    |> Multi.execute(&listing_available(&1, actor))
    |> Multi.execute(&publish_listing(&1, actor))
  end

  # Apply

  def apply(%Listing{}, %ListingCreated{} = event) do
    %{listing_id: listing_id, name: name, price: price, total: total, corpo_id: corpo_id} = event

    %Listing{
      listing_id: listing_id,
      name: name,
      total: total,
      price: price,
      reserved: 0,
      corpo_id: corpo_id,
      public: false
    }
  end

  def apply(%Listing{} = listing, %ListingPublished{}) do
    %Listing{listing | public: true}
  end

  def apply(%Listing{} = listing, %ListingPriceChanged{
        price: price
      }) do
    %Listing{listing | price: price}
  end

  def apply(%Listing{} = listing, %ListingNameChanged{
        name: name
      }) do
    %Listing{listing | name: name}
  end
end
