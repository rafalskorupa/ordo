defmodule Ordo.InventoryTest do
  use Ordo.DataCase

  alias Ordo.Inventory
  import Ordo.AuthFixtures
  import Ordo.ListingsFixtures

  describe "create_listing/2" do
    setup [:create_corpo_account]

    test "it creates new private listing", %{actor: actor} do
      assert {:ok, %{} = listing} =
               Inventory.create_listing(
                 actor,
                 %{name: "Listing", total: 20, price: 2999}
               )

      assert listing.corpo_id == actor.corpo.id
      assert listing.name == "Listing"
      assert listing.total == 20
      assert listing.reserved == 0
      refute listing.public
    end

    test "it returns changeset error", %{actor: actor} do
      assert {:error, %Ecto.Changeset{} = changeset} =
               Inventory.create_listing(
                 actor,
                 %{name: "", total: nil}
               )

      assert errors_on(changeset) == %{
               total: ["can't be blank"],
               name: ["can't be blank"],
               price: ["can't be blank"]
             }
    end
  end

  describe "publish_listing/2" do
    setup [:create_corpo_account]

    test "it publishes listing", %{actor: actor} = identity do
      %{listing: listing} = create_listing(identity)

      assert {:ok, %{} = listing} =
               Inventory.publish_listing(
                 actor,
                 listing
               )

      assert listing.public
    end

    test "it returns already_published error", %{actor: actor} = identity do
      %{listing: listing} = create_listing(identity, %{public: true})

      assert {:error, :listing_already_published} =
               Inventory.publish_listing(
                 actor,
                 listing
               )
    end
  end
end
