defmodule Ordo.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use Ordo.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Ordo.Repo

      use Oban.Testing, repo: Ordo.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Ordo.DataCase
      import Commanded.Assertions.EventAssertions
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

    :ok
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
