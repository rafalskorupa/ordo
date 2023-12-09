defmodule Ordo.Inventory do
  @doc """
  Module to interact with Shop Inventory as seller
  """

  alias Ordo.Inventory
  alias Ordo.Listings

  alias Ordo.Repo
  import Ecto.Query

  # Commands
  alias Inventory.Commands.CreateListing
  alias Inventory.Commands.PublishListing
  alias Inventory.Commands.UpdateListing

  def get_listing!(actor, listing_id) do
    Listings.Projections.Listing
    |> actor_scope(actor)
    |> Repo.get!(listing_id)
  end

  def list_listings(actor) do
    Listings.Projections.Listing
    |> actor_scope(actor)
    |> Repo.all()
  end

  def create_listing(actor, attrs) do
    with {:ok, command} <- CreateListing.build(actor, attrs),
         :ok <- Ordo.App.dispatch(command, consistency: :strong) do
      {:ok, get_listing!(actor, command.listing_id)}
    end
  end

  def create_listing_changeset(command \\ %Inventory.Commands.CreateListing{}, attrs) do
    CreateListing.changeset(command, attrs)
  end

  def update_listing(actor, listing, attrs) do
    with {:ok, command} <- UpdateListing.build(actor, listing, attrs),
         :ok <- Ordo.App.dispatch(command, consistency: :strong) do
      {:ok, get_listing!(actor, command.listing_id)}
    end
  end

  def update_listing_changeset(%Ordo.Listings.Projections.Listing{} = listing, attrs) do
    UpdateListing.changeset(
      %UpdateListing{name: listing.name, price: listing.price},
      attrs
    )
  end

  def publish_listing(actor, listing) do
    with {:ok, command} <- PublishListing.build(actor, listing),
         :ok <- Ordo.App.dispatch(command, consistency: :strong) do
      {:ok, get_listing!(actor, command.listing_id)}
    end
  end

  defp actor_scope(query, %{corpo: %{id: corpo_id}}) do
    where(query, corpo_id: ^corpo_id)
  end
end
