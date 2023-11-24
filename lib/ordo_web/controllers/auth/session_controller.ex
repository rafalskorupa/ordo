defmodule OrdoWeb.Authentication.SessionController do
  use OrdoWeb, :controller

  alias Ordo.Authentication
  alias OrdoWeb.ActorAuth

  def create(conn, %{"register" => credentials}) do
    case Authentication.sign_in(credentials) do
      {:ok, actor} ->
        conn
        |> put_flash(:info, "Account created successfully!")
        |> ActorAuth.log_in_actor(actor, credentials)

      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:email, Map.get(credentials, "email"))
        |> put_flash(:error, "Invalid email or password")
        |> redirect(to: ~p"/auth/sign_in")
    end
  end

  def create(conn, %{"login" => credentials}) do
    case Authentication.sign_in(credentials) do
      {:ok, actor} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> ActorAuth.log_in_actor(actor, credentials)

      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:email, Map.get(credentials, "email"))
        |> put_flash(:error, "Invalid email or password")
        |> redirect(to: ~p"/auth/sign_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> ActorAuth.log_out_actor()
  end
end
