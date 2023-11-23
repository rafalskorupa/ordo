defmodule OrdoWeb.ListLive.Show do
  use OrdoWeb, :live_view

  alias Ordo.Tasks

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:list, Tasks.get_list!(socket.assigns.actor, id))}
  end

  defp page_title(:show), do: "Show List"
  defp page_title(:edit), do: "Edit List"
end
