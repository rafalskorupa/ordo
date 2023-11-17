defmodule Ordo.Authentication.Aggregates.Session do
  defstruct [:session_id, :account_id]

  alias Ordo.Authentication.Aggregates.Session

  alias Ordo.Authentication.Commands.CreateSession
  alias Ordo.Authentication.Commands.VerifySession

  alias Ordo.Authentication.Events.SessionCreated

  def execute(%Session{}, %CreateSession{session_id: session_id, actor: actor}) do
    %{account: %{id: account_id}} = actor
    with :ok <- Ordo.App.dispatch(%Ordo.Authentication.Commands.VerifyAccount{account_id: account_id}) do
      %SessionCreated{
        account_id: account_id,
        session_id: session_id
      }
    end
  end

  def execute(%Session{session_id: nil}, %VerifySession{}) do
    {:error, :session_invalid}
  end

  def execute(%Session{}, %VerifySession{}), do: :ok

  def apply(%Session{}, %SessionCreated{} = ev) do
    %Session{
      session_id: ev.session_id,
      account_id: ev.account_id
    }
  end
end
