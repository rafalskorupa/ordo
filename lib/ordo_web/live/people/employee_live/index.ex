defmodule OrdoWeb.People.EmployeeLive.Index do
  use OrdoWeb, :live_view

  alias Ordo.People
  alias Ordo.People.Projections.Employee

  @impl true
  def mount(_params, _session, socket) do
    actor = socket.assigns.actor

    {:ok, stream(socket, :employees, People.list_employees(actor))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    actor = socket.assigns.actor

    socket
    |> assign(:page_title, "Edit Employee")
    |> assign(:employee, People.get_employee!(actor, id))
  end

  defp apply_action(socket, :invite, %{"id" => id}) do
    actor = socket.assigns.actor

    socket
    |> assign(:page_title, "Invite Employee")
    |> assign(:employee, People.get_employee!(actor, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Employee")
    |> assign(:employee, %Employee{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Employees")
    |> assign(:employee, nil)
  end

  @impl true
  def handle_info({_, {:saved, employee}}, socket) do
    {:noreply, stream_insert(socket, :employees, employee)}
  end

  def handle_info({OrdoWeb.People.EmployeeLive.InvitationComponent, {:invited, employee}}, socket) do
    {:noreply, stream_insert(socket, :employees, employee)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    employee = People.get_employee!(socket.assigns.actor, id)
    {:ok, _} = People.delete_employee(socket.assigns.actor, employee)

    {:noreply, stream_delete(socket, :employees, employee)}
  end
end
