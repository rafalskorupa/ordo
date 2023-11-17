defmodule OrdoWeb.Authentication.RegisterLive do
  use OrdoWeb, :live_view

  alias Ordo.Authentication

  @impl true
  def mount(_params, _session, socket) do
    changeset = Authentication.register_changeset(%{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, layout: {OrdoWeb.Layouts, :auth}, temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"register" => user_params}, socket) do
    case Authentication.register(user_params) do
      :ok ->
        changeset = Authentication.register_changeset(user_params)

        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"register" => register_params}, socket) do
    changeset = Authentication.register_changeset(register_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "register")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
