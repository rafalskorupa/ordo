defmodule OrdoWeb.ListLive.Show do
  use OrdoWeb, :live_view

  alias Ordo.Tasks

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    changeset = Tasks.Commands.CreateTask.changeset(%Tasks.Commands.CreateTask{list_id: id}, %{})

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:list, Tasks.get_list!(socket.assigns.actor, id))
     |> assign_add_task_form(changeset)
     |> stream(:tasks, Tasks.list_tasks(socket.assigns.actor, id))}
  end

  defp page_title(:show), do: "Show List"
  defp page_title(:edit), do: "Edit List"

  @impl true
  def handle_event("add_task", %{"create_task" => params}, socket) do
    case Tasks.create_task(socket.assigns.actor, params) do
      {:ok, task} ->
        {:noreply, stream_insert(socket, :tasks, task)}

      {:error, changeset} ->
        {:noreply, assign_add_task_form(socket, changeset)}
    end
  end

  def handle_event("archive", %{"task_id" => task_id}, socket) do
    task = Tasks.get_task!(socket.assigns.actor, task_id)
    {:ok, task} = Tasks.archive_task(socket.assigns.actor, task)

    {:noreply, stream_insert(socket, :tasks, task)}
  end

  def handle_event("complete", %{"task_id" => task_id}, socket) do
    task = Tasks.get_task!(socket.assigns.actor, task_id)
    {:ok, task} = Tasks.complete_task(socket.assigns.actor, task)

    {:noreply, stream_insert(socket, :tasks, task)}
  end

  defp assign_add_task_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :add_task_form, to_form(changeset, as: :create_task))
  end
end
