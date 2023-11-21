defmodule OrdoWeb.People.EmployeeLive.Show do
  use OrdoWeb, :live_view

  alias Ordo.People

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    actor = socket.assigns.actor

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:employee, People.get_employee!(actor, id))}
  end

  defp page_title(:show), do: "Show Employee"
  defp page_title(:edit), do: "Edit Employee"
end
