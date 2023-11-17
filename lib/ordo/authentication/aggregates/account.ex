defmodule Ordo.Authentication.Aggregates.Account do
  defstruct [:account_id]

  alias Ordo.Authentication.Aggregates.Account

  alias Ordo.Authentication.Commands.CreateAccount
  alias Ordo.Authentication.Commands.VerifyAccount

  alias Ordo.Authentication.Events.AccountCreated

  def execute(%Account{}, %CreateAccount{} = command) do
    %{account_id: account_id} = command

    %AccountCreated{account_id: account_id}
  end

  def execute(%Account{account_id: account_id}, %VerifyAccount{}) do
    if account_id do
      :ok
    else
      {:error, :invalid_account_id}
    end
  end

  def apply(%Account{}, %AccountCreated{account_id: account_id}) do
    %Account{account_id: account_id}
  end
end
