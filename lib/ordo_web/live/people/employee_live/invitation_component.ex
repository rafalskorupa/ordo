defmodule OrdoWeb.EmployeeLive.InvitationComponent do
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
        <.input field={@form[:email]} type="email" label="Email" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Employee</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{} = assigns, socket) do
    changeset = People.invite_employee_by_email_changeset(%{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"invite_by_email" => invitation_params}, socket) do
    changeset =
      invitation_params
      |> People.invite_employee_by_email_changeset()
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"invite_by_email" => invitation_params}, socket) do
    case People.invite_employee_by_email(
           socket.assigns.actor,
           socket.assigns.employee,
           invitation_params
         ) do
      :ok ->
        employee = People.get_employee!(socket.assigns.actor, socket.assigns.employee.id)

        notify_parent({:invited, employee})

        {:noreply,
         socket
         |> put_flash(:info, "Employee invited successfully")
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
