defmodule Ordo.Authentication.Projectors.Account do
  use Commanded.Projections.Ecto,
    application: Ordo.App,
    name: "account-projection",
    repo: Ordo.Repo,
    consistency: :strong

  alias Ordo.Repo

  alias Ordo.Authentication.Events
  alias Ordo.Authentication.Projections

  project(%Events.AccountCreated{account_id: account_id}, _metadata, fn multi ->
    Ecto.Multi.insert(multi, :account, %Projections.Account{id: account_id})
  end)

  project(
    %Events.CredentialsCreated{
      account_id: account_id,
      email: email,
      hashed_password: hashed_password
    },
    _metadata,
    fn multi ->
      case Repo.get(Projections.Account, account_id, skip_org_id: true) do
        nil ->
          multi

        %{} = account ->
          Ecto.Multi.update(
            multi,
            :credentials,
            Ecto.Changeset.change(account, email: email, hashed_password: hashed_password)
          )
      end
    end
  )

  project(
    %Events.PasswordChanged{account_id: account_id, hashed_password: hashed_password},
    _metadata,
    fn multi ->
      case Repo.get(Projections.Account, account_id, skip_org_id: true) do
        nil ->
          multi

        %{} = account ->
          Ecto.Multi.update(
            multi,
            :credentials,
            Ecto.Changeset.change(account, hashed_password: hashed_password)
          )
      end
    end
  )
end
