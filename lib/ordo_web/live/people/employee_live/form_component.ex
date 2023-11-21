defmodule OrdoWeb.EmployeeLive.FormComponent do
  use OrdoWeb, :live_component

  alias Ordo.People

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage employee records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="employee-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:first_name]} type="text" label="First name" />
        <.input field={@form[:last_name]} type="text" label="Last name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Employee</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{employee: employee} = assigns, socket) do
    changeset =
      if !employee.id do
        People.create_employee_changeset(%{})
      else
        People.update_employee_changeset(employee, %{})
      end
      |> IO.inspect()

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"create_employee" => employee_params}, socket) do
    changeset =
      employee_params
      |> People.create_employee_changeset()
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("validate", %{"update_employee" => employee_params}, socket) do
    changeset =
      socket.assigns.employee
      |> People.update_employee_changeset(employee_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"create_employee" => employee_params}, socket) do
    case People.create_employee(socket.assigns.actor, employee_params) do
      {:ok, employee} ->
        notify_parent({:saved, employee})

        {:noreply,
         socket
         |> put_flash(:info, "Employee created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("save", %{"update_employee" => employee_params}, socket) do
    case People.update_employee(socket.assigns.actor, socket.assigns.employee, employee_params) do
      {:ok, employee} ->
        notify_parent({:saved, employee})

        {:noreply,
         socket
         |> put_flash(:info, "Employee updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
