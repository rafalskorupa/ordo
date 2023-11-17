defmodule OrdoWeb.Authentication.SessionController do
  use OrdoWeb, :controller

  alias Ordo.Authentication
  alias OrdoWeb.ActorAuth

  def create(conn, %{"register" => credentials}) do
    with {:ok, actor} <- Authentication.sign_in(credentials) do
      conn
      |> put_flash(:info, "Account created successfully!")
      |> ActorAuth.log_in_actor(actor, credentials)
    else
      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:email, Map.get(credentials, "email"))
        |> put_flash(:error, "Invalid email or password")
        |> redirect(to: ~p"/auth/sign_in")
    end
  end

  def create(conn, %{"login" => credentials}) do
    with {:ok, actor} <- Authentication.sign_in(credentials) do
      conn
      |> put_flash(:info, "Welcome back!")
      |> ActorAuth.log_in_actor(actor, credentials)
    else
      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:email, Map.get(credentials, "email"))
        |> put_flash(:error, "Invalid email or password")
        |> redirect(to: ~p"/auth/sign_in")
    end
  end

  # TODO: Handle errors? Maybe? Cleanup? Anything?
  def update(conn, %{"corpo_id" => corpo_id}) do

    session_id = ActorAuth.get_session_id(conn)
    corpo = Ordo.Repo.get(Ordo.Corpos.Projections.Corpo, corpo_id)

    :ok = Authentication.set_active_corpo_id(session_id, corpo_id)

    conn
    |> put_flash(:info, "Logged to #{corpo.name}")
    |> redirect(to: ~p"/")
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> ActorAuth.log_out_actor()
  end
end
