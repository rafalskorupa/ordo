defmodule Ordo.AuthFixtures do
  alias Ordo.Repo
  alias Ordo.Authentication

  alias Ordo.Authentication.Projections.Account
  alias Ordo.Authentication.Projections.Session

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def create_session(%{actor: actor}) do
    {:ok, session_id} = Authentication.create_session(actor)

    %{session: Repo.get_by!(Session, session_id)}
  end

  def valid_session_attributes(attrs \\ %{}) do
    attrs
    |> Map.put_new_lazy(:account_id, fn ->
      %{account: account} = create_account()
      account.id
    end)
    |> Map.put_new_lazy(:corpo_id, fn -> nil end)
  end

  def create_account(attrs \\ %{}) do
    register_attrs = valid_account_attributes(attrs)
    Authentication.register(register_attrs)

    account = Repo.get_by!(Account, email: register_attrs.email)
    actor = Ordo.Actor.build(%{account: account})

    %{account: account, actor: actor}
  end

  def valid_account_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end
end
