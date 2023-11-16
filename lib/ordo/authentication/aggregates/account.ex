defmodule Ordo.Authentication.Aggregates.Account do
  defstruct [:account_id]

  alias Ordo.Authentication.Aggregates.Account

  alias Ordo.Authentication.Commands.CreateAccount
  alias Ordo.Authentication.Events.AccountCreated

  def execute(%Account{}, %CreateAccount{} = command) do
    %{account_id: account_id} = command

    %AccountCreated{account_id: account_id}
  end

  def apply(%Account{}, %AccountCreated{account_id: account_id}) do
    %Account{account_id: account_id}
  end
end
