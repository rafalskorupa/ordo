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

  def create_corpo_account(attrs \\ %{}) do
    %{account: account, actor: actor} = create_account()

    %{corpo: corpo} =
      if Map.has_key?(attrs, :corpo) do
        %{corpo: attrs[:corpo]}
      else
        create_corpo(%{actor: actor})
      end

    employee = Ordo.People.get_actor_employee!(actor, corpo.id)

    actor = Ordo.Actor.set_corpo(actor, employee)

    %{account: account, actor: actor, employee: employee, corpo: corpo}
  end

  def create_corpo(attrs \\ %{}) do
    actor =
      if Map.has_key?(attrs, :actor) do
        attrs[:actor]
      else
        %{actor: actor} = create_account()
        actor
      end

    attrs = valid_corpo_attributes(attrs)

    {:ok, corpo} = Ordo.Corpos.create_corpo(actor, attrs)

    %{corpo: corpo}
  end

  def valid_corpo_attributes(attrs \\ %{}) do
    attrs
    |> Map.take([:name])
    |> Enum.into(%{
      name: "Arasaka"
    })
  end

  def valid_account_attributes(attrs \\ %{}) do
    attrs
    |> Map.take([:email, :password])
    |> Enum.into(%{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end
end
