defmodule OrdoWeb.ListingLiveTest do
  use OrdoWeb.ConnCase

  import Phoenix.LiveViewTest

  import Ordo.AuthFixtures
  import Ordo.ListingsFixtures

  describe "Index" do
    setup [:create_corpo_account, :create_public_listing]

    test "lists all listings", %{conn: conn, listing: listing} do
      {:ok, _index_live, html} = live(conn, ~p"/marketplace/listings")

      assert html =~ "Listing Listings"
      assert html =~ listing.name
    end
  end

  describe "Show" do
    setup [:create_corpo_account, :create_public_listing]

    test "displays listing", %{conn: conn, listing: listing} do
      {:ok, _show_live, html} = live(conn, ~p"/marketplace/listings/#{listing}")

      assert html =~ "Show Listing"
      assert html =~ listing.name
    end
  end
end
