defmodule OrdoWeb.ListLive.Index do
  use OrdoWeb, :live_view

  alias Ordo.Tasks
  alias Ordo.Tasks.Projections.List

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :task_lists, Tasks.list_task_lists(socket.assigns.actor))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit List")
    |> assign(:list, Tasks.get_list!(socket.assigns.actor, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New List")
    |> assign(:list, %List{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Task lists")
    |> assign(:list, nil)
  end

  @impl true
  def handle_info({OrdoWeb.ListLive.FormComponent, {:saved, list}}, socket) do
    {:noreply, stream_insert(socket, :task_lists, list)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    list = Tasks.get_list!(socket.assigns.actor, id)
    {:ok, _} = Tasks.delete_list(socket.assigns.actor, list)

    {:noreply, stream_delete(socket, :task_lists, list)}
  end
end
