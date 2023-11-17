defmodule Ordo.AuthFixtures do
  alias Ordo.Repo
  alias Ordo.Authentication

  alias Ordo.Authentication.Projections.Account

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

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
