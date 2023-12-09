defmodule OrdoWeb.Marketplace.ListingLive.Show do
  use OrdoWeb, :live_view

  alias Ordo.Marketplace

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket, layout: {OrdoWeb.Layouts, :marketplace}}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:listing, Marketplace.get_listing!(id))}
  end

  defp page_title(:show), do: "Show Listing"
end
