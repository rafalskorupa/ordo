defmodule OrdoWeb.Marketplace.ListingLive.Index do
  use OrdoWeb, :live_view

  alias Ordo.Marketplace

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :listings, Marketplace.list_listings()),
     layout: {OrdoWeb.Layouts, :marketplace}}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Listings")
    |> assign(:listing, nil)
  end
end
