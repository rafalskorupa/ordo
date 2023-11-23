defmodule OrdoWeb.ListLive.FormComponent do
  use OrdoWeb, :live_component

  alias Ordo.Tasks

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage list records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="list-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save List</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  defp form_changeset(nil, params) do
    Tasks.create_list_changeset(params)
  end

  defp form_changeset(list, params) do
    Tasks.update_list_changeset(list, params)
  end

  @impl true
  def update(%{list: list} = assigns, socket) do
    changeset = form_changeset(list, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"list" => list_params}, socket) do
    changeset = form_changeset(socket.assigns.list, list_params) |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"list" => list_params}, socket) do
    save_list(socket, socket.assigns.action, list_params)
  end

  defp save_list(socket, :edit, list_params) do
    case Tasks.update_list(socket.assigns.actor, socket.assigns.list, list_params) do
      {:ok, list} ->
        notify_parent({:saved, list})

        {:noreply,
         socket
         |> put_flash(:info, "List updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_list(socket, :new, list_params) do
    case Tasks.create_list(socket.assigns.actor, list_params) do
      {:ok, list} ->
        notify_parent({:saved, list})

        {:noreply,
         socket
         |> put_flash(:info, "List created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset, as: :list))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
