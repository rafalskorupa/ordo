defmodule OrdoWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use OrdoWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint OrdoWeb.Endpoint

      use OrdoWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import OrdoWeb.ConnCase
    end
  end

  setup _tags do
    {:ok, _} = Application.ensure_all_started(:ordo)

    on_exit(fn ->
      case Application.stop(:ordo) do
        :ok -> :ok
        {:error, {:not_started, :ordo}} -> :ok
      end

      Ordo.Storage.reset!()
    end)

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_user(%{conn: conn}) do
    %{actor: actor} = Ordo.AuthFixtures.create_account()
    %{conn: log_in_actor(conn, actor), actor: actor}
  end

  def register_and_log_in_corpo_actor(%{conn: conn}) do
    %{actor: actor, corpo: corpo} = Ordo.AuthFixtures.create_corpo_account()

    %{conn: log_in_actor(conn, actor), actor: actor, corpo: corpo}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_actor(conn, actor) do
    {:ok, token} = Ordo.Authentication.create_session(actor)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:actor_token, OrdoWeb.ActorAuth.encode_token(token))
  end
end
