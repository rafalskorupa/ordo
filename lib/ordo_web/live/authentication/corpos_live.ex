defmodule OrdoWeb.Authentication.CorposLive do
  use OrdoWeb, :live_view

  alias Ordo.Corpos
  alias Ordo.Invitations

  @impl true
  def mount(_parmas, _session, socket) do
    actor = socket.assigns.actor

    changeset = Corpos.create_corpo_changeset(%{})

    corpos = Corpos.list_corpos(actor)
    invitations = Invitations.list_invitations(actor)

    socket = socket |> assign(corpos: corpos, invitations: invitations) |> assign_form(changeset)

    {:ok, socket, layout: {OrdoWeb.Layouts, :auth}}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "create_corpo")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"create_corpo" => corpo_params}, socket) do
    case Corpos.create_corpo(socket.assigns.actor, corpo_params) do
      {:ok, corpo} ->
        {:noreply, socket |> redirect(to: ~p"/app/#{corpo.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"create_corpo" => corpo_params}, socket) do
    changeset = Corpos.create_corpo_changeset(corpo_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end
end
