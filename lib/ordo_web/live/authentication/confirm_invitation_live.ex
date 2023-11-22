defmodule OrdoWeb.Authentication.ConfirmInvitationLive do
  use OrdoWeb, :live_view

  alias Ordo.Invitations

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket, layout: {OrdoWeb.Layouts, :auth}}
  end

  @impl true
  def handle_params(%{"invitation_id" => invitation_id} = _params, _url, socket) do
    case Invitations.get_invitation(socket.assigns.actor, invitation_id) do
      nil ->
        {:noreply, invalid_invitation_redirect(socket)}

      %{} = invitation ->
        socket = assign(socket, :invitation, invitation)
        socket = assign(socket, :form, to_form(%{"invitation_id" => invitation.id}))
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("confirm", %{"invitation_id" => invitation_id}, socket) do
    actor = socket.assigns.actor
    %{id: ^invitation_id} = invitation = socket.assigns.invitation

    case Invitations.accept_invitation(actor, invitation) do
      :ok ->
        {:noreply,
         socket |> put_flash(:info, "Invitation Accepted") |> redirect(to: ~p"/app/#{invitation.corpo.id}")}

      _ ->
        {:noreply,
         socket |> put_flash(:error, "Invalid invitation") |> push_patch(to: ~p"/auth/corpos")}
    end
  end

  defp invalid_invitation_redirect(socket) do
    socket |> put_flash(:error, "Invalid invitation") |> push_patch(to: ~p"/auth/corpos")
  end
end
