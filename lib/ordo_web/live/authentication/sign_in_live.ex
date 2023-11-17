defmodule OrdoWeb.Authentication.SignInLive do
  use OrdoWeb, :live_view

  alias Ordo.Authentication

  @impl true
  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "login")

    {:ok, assign(socket, form: form),
     layout: {OrdoWeb.Layouts, :auth}, temporary_assigns: [form: form]}
  end
end
