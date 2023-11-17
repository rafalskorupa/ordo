defmodule OrdoWeb.App.DashboardLive do
  use OrdoWeb, :live_view

  @impl true
  def mount(_, _, socket) do
    {:ok, socket}
  end
end
