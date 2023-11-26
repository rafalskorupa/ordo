defmodule OrdoWeb.ActorAuth do
  @moduledoc """
  Module for authorization in Web App
  """
  use OrdoWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Ordo.Authentication

  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_ordo_web_account_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  def encode_token(token) do
    Base.encode64(token, padding: false)
  end

  def decode_token(token) do
    Base.decode64!(token)
  end

  @doc """
  Handles mounting and authenticating the current_user in LiveViews.

  ## `on_mount` arguments

    * `:mount_current_actor` - Assigns current_user
      to socket assigns based on actor_token, or nil if
      there's no actor_token or no matching user.

    * `:ensure_authenticated` - Authenticates the user from the session,
      and assigns the current_user to socket assigns based
      on actor_token.
      Redirects to login page if there's no logged user.

    * `:redirect_if_user_is_authenticated` - Authenticates the user from the session.
      Redirects to signed_in_path if there's a logged user.

  ## Examples

  Use the `on_mount` lifecycle macro in LiveViews to mount or authenticate
  the current_user:

      defmodule OrdoWeb.PageLive do
        use OrdoWeb, :live_view

        on_mount {OrdoWeb.UserAuth, :mount_current_actor}
        ...
      end

  Or use the `live_session` of your router to invoke the on_mount callback:

      live_session :authenticated, on_mount: [{OrdoWeb.UserAuth, :ensure_authenticated}] do
        live "/profile", ProfileLive, :index
      end
  """
  def on_mount(:mount_current_actor, _params, session, socket) do
    {:cont, mount_current_actor(socket, session)}
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    socket = mount_current_actor(socket, session)

    if Ordo.Actor.authenticated?(socket.assigns.actor) do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
        |> Phoenix.LiveView.redirect(to: ~p"/auth/log_in")

      {:halt, socket}
    end
  end

  def on_mount(:ensure_corpo_actor, :not_mounted_at_router, session, socket) do
    on_mount(:ensure_corpo_actor, session, session, socket)
  end

  def on_mount(:ensure_corpo_actor, %{"corpo_id" => corpo_id}, session, socket) do
    socket = mount_current_actor(socket, session)

    case Authentication.get_corpo_actor(socket.assigns.actor, corpo_id) do
      {:ok, actor} ->
        socket =
          socket
          |> Phoenix.Component.assign(:actor, actor)
          |> Phoenix.Component.assign(:corpo, actor.corpo)

        {:cont, socket}

      {:error, :no_access_to_corpo} ->
        socket =
          socket
          |> Phoenix.LiveView.put_flash(:error, "You don't have access to this page")
          |> Phoenix.LiveView.redirect(to: ~p"/auth/corpos")

        {:halt, socket}
    end
  end

  def on_mount(:redirect_if_actor_is_authenticated, _params, session, socket) do
    socket = mount_current_actor(socket, session)

    if Ordo.Actor.authenticated?(socket.assigns.actor) do
      {:halt, Phoenix.LiveView.redirect(socket, to: signed_in_path(socket))}
    else
      {:cont, socket}
    end
  end

  def mount_current_actor(socket, session) do
    Phoenix.Component.assign_new(socket, :actor, fn ->
      with token when is_binary(token) <- session["actor_token"],
           session_id = decode_token(token),
           {:ok, actor} <- Authentication.get_actor_by_session_id(session_id) do
        actor
      else
        _ -> Ordo.Actor.build(nil)
      end
    end)
  end

  @doc """
  Logs the actor in.

  It renews the session ID and clears the whole session
  to avoid fixation attacks. See the renew_session
  function to customize this behaviour.

  It also sets a `:live_socket_id` key in the session,
  so LiveView sessions are identified and automatically
  disconnected on log out. The line can be safely removed
  if you are not using LiveView.
  """
  def log_in_actor(conn, actor, params \\ %{}) do
    {:ok, session_id} = Authentication.create_session(actor)
    token = encode_token(session_id)

    user_return_to = get_session(conn, :user_return_to)

    conn
    |> renew_session()
    |> maybe_write_remember_me_cookie(token, params)
    |> put_token_in_session(token)
    |> redirect(to: user_return_to || signed_in_path(conn))
  end

  defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
    put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  end

  defp maybe_write_remember_me_cookie(conn, _token, _params) do
    conn
  end

  # This function renews the web session and erases the whole
  # session to avoid fixation attacks. If there is any data
  # in the session you may want to preserve after log in/log out,
  # you must explicitly fetch the session data before clearing
  # and then immediately set it after clearing, for example:

  # defp renew_session(conn) do
  #   preferred_locale = get_session(conn, :preferred_locale)

  #   conn
  #   |> configure_session(renew: true)
  #   |> clear_session()
  #   |> put_session(:preferred_locale, preferred_locale)
  # end
  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  @doc """
  Logs the user out.

  It clears all session data for safety. See renew_session.
  """
  def log_out_actor(conn) do
    token = get_session(conn, :actor_token)
    session_id = decode_token(token)

    session_id != "" && Authentication.delete_session(session_id)

    if live_socket_id = get_session(conn, :live_socket_id) do
      OrdoWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
    |> redirect(to: ~p"/")
  end

  @doc """
  Authenticates the actor by looking into the session
  and remember me token
  """
  def fetch_current_actor(conn, _opts) do
    {session_id, conn} = ensure_actor_token(conn)

    with session_id when is_binary(session_id) <- session_id,
         {:ok, actor} <- Authentication.get_actor_by_session_id(session_id) do
      assign(conn, :actor, actor)
    else
      _ ->
        assign(conn, :actor, Ordo.Actor.build(nil))
    end
  end

  def get_session_id(conn) do
    conn
    |> get_session(:actor_token)
    |> decode_token()
  end

  defp ensure_actor_token(conn) do
    if token = get_session(conn, :actor_token) do
      {decode_token(token), conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if token = conn.cookies[@remember_me_cookie] do
        {token, put_token_in_session(conn, token)}
      else
        {nil, conn}
      end
    end
  end

  @doc """
  Used for routes that require the user to not be authenticated.
  """
  def redirect_if_actor_is_authenticated(conn, _opts) do
    if Ordo.Actor.authenticated?(conn.assigns[:actor]) do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_actor(conn, _opts) do
    if Ordo.Actor.authenticated?(conn.assigns[:actor]) do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> maybe_store_return_to()
      |> redirect(to: ~p"/auth/sign_in")
      |> halt()
    end
  end

  def ensure_corpo(conn, _opts) do
    if Ordo.Actor.has_corpo?(conn.assigns.actor) do
      conn
    else
      conn
      |> put_flash(:error, "You must select a corpo to access this page.")
      |> maybe_store_return_to()
      |> redirect(to: ~p"/auth/corpos")
      |> halt()
    end
  end

  defp put_token_in_session(conn, token) do
    conn
    |> put_session(:actor_token, token)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :user_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp signed_in_path(_conn), do: ~p"/auth/corpos"
end
