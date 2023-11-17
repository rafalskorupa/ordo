defmodule OrdoWeb.Authentication.SignInLive do
  use OrdoWeb, :live_view

  alias Ordo.Authentication

  @impl true
  def mount(_params, _session, socket) do
    changeset = Authentication.sign_in_changeset(%{})

    socket =
      socket
      |> assign(trigger_submit: false, credentials_valid: false)
      |> assign_form(changeset)

    {:ok, socket, layout: {OrdoWeb.Layouts, :auth}, temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"login" => login_params}, socket) do
    case Authentication.sign_in(login_params) do
      {:ok, _actor} ->
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(credentials_valid: true) |> assign_form(changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "login")

    if changeset.valid? do
      assign(socket, form: form, credentials_valid: false)
    else
      assign(socket, form: form)
    end
  end
end
