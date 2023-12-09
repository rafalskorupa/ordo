defmodule OrdoWeb.App.Inventory.ListingsLive.Index do
  use OrdoWeb, :live_view

  alias Ordo.Inventory

  @impl true
  def mount(_params, _session, socket) do
    actor = socket.assigns.actor

    {:ok, stream(socket, :listings, Inventory.list_listings(actor))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    actor = socket.assigns.actor

    socket
    |> assign(:page_title, "Edit Listing")
    |> assign(:listing, Inventory.get_listing!(actor, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Listing")
    |> assign(:listing, %{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "All Listings")
    |> assign(:employee, nil)
  end

  @impl true
  def handle_info({_, {:saved, listing}}, socket) do
    {:noreply, stream_insert(socket, :listings, listing)}
  end

  @impl true
  def handle_event("publish", %{"id" => id}, socket) do
    listing = Inventory.get_listing!(socket.assigns.actor, id)
    {:ok, listing} = Inventory.publish_listing(socket.assigns.actor, listing)

    {:noreply, stream_insert(socket, :listings, listing)}
  end
end
