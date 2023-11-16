defmodule OrdoWeb.OrganisationLive.Show do
  use OrdoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    organisation = socket.assigns.current_user.organisation

    {:ok,
     socket
     |> assign(:page_title, organisation.name)
     |> assign(:organisation, organisation)}
  end
end
