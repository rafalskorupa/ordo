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
        {:noreply, stream_insert(socket, :tasks, task, at: 0)}

      {:error, changeset} ->
        {:noreply, assign_add_task_form(socket, changeset)}
    end
  end

  def handle_event("archive", %{"task_id" => task_id}, socket) do
    task = Tasks.get_task!(socket.assigns.actor, task_id)

    case Tasks.archive_task(socket.assigns.actor, task) do
      {:ok, task} ->
        {:noreply, stream_delete(socket, :tasks, task)}

      {:error, :task_already_archived} ->
        {:noreply, put_flash(socket, :error, "Task is already archived")}
    end
  end

  def handle_event("complete", %{"task_id" => task_id}, socket) do
    task = Tasks.get_task!(socket.assigns.actor, task_id)

    case Tasks.complete_task(socket.assigns.actor, task) do
      {:ok, task} ->
        {:noreply, stream_insert(socket, :tasks, task, at: 500)}
    end
  end

  def handle_event("assign_yourself", %{"task_id" => task_id}, socket) do
    task = Tasks.get_task!(socket.assigns.actor, task_id)

    case Tasks.assign_to_task(socket.assigns.actor, task, %{
           employee_id: socket.assigns.actor.employee.id
         }) do
      {:ok, task} ->
        {:noreply, stream_insert(socket, :tasks, task)}

      {:error, :already_assigned_to_task} ->
        {:noreply, put_flash(socket, :error, "You are already assigned to this task")}
    end
  end

  def handle_event("deassign", %{"task_id" => task_id, "employee_id" => employee_id}, socket) do
    task = Tasks.get_task!(socket.assigns.actor, task_id)

    case Tasks.deassign_from_task(socket.assigns.actor, task, %{
           employee_id: employee_id
         }) do
      {:ok, task} ->
        {:noreply, stream_insert(socket, :tasks, task)}

      {:error, :not_assigned_to_task} ->
        socket = stream_insert(socket, :tasks, task)
        {:noreply, put_flash(socket, :error, "Employee is already deassigned from task")}
    end
  end

  defp assign_add_task_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :add_task_form, to_form(changeset, as: :create_task))
  end
end
