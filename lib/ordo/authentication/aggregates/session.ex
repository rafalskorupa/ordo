defmodule Ordo.Authentication.Aggregates.Session do
  defstruct [:session_id, :account_id, :corpo_id]
  alias Commanded.Aggregate.Multi

  alias Ordo.Authentication.Internal
  alias Ordo.Authentication.Aggregates.Session

  alias Ordo.Authentication.Commands.CreateSession
  alias Ordo.Authentication.Commands.VerifySession
  alias Ordo.Authentication.Commands.SetSessionCorpo

  alias Ordo.Authentication.Events.SessionCreated
  alias Ordo.Authentication.Events.SessionCorpoSet

  def init_session(%Session{session_id: session_id}, account_id) do
    %SessionCreated{
      session_id: session_id,
      account_id: account_id
    }
  end

  def set_corpo_id(%Session{}, nil) do
    :ok
  end

  def set_corpo_id(%Session{session_id: session_id}, corpo_id) do
    %SessionCorpoSet{
      session_id: session_id,
      corpo_id: corpo_id
    }
  end

  def execute(%Session{}, %CreateSession{session_id: session_id, actor: actor}) do
    %{account: %{id: account_id}} = actor

    with :ok <-
           Ordo.App.dispatch(%Ordo.Authentication.Commands.VerifyAccount{account_id: account_id}) do
      %Session{session_id: session_id}
      |> Multi.new()
      |> Multi.execute(:init, &init_session(&1, account_id))
      |> Multi.execute(:set_corpo, &set_corpo_id(&1, Ordo.Actor.corpo_id(actor)))
    end
  end

  def execute(%Session{session_id: nil}, _) do
    {:error, :session_invalid}
  end

  def execute(%Session{} = session, %SetSessionCorpo{} = command) do
    SetSessionCorpo.validate!(command)

    with :ok <-
           Internal.verify_account_has_access_to_corpo(%{
             account_id: session.account_id,
             corpo_id: command.corpo_id
           }) do
      set_corpo_id(session, command.corpo_id)
    end
  end

  def execute(%Session{}, %VerifySession{}), do: :ok

  def apply(%Session{}, %SessionCreated{} = ev) do
    %Session{
      session_id: ev.session_id,
      account_id: ev.account_id
    }
  end

  def apply(%Session{} = session, %SessionCorpoSet{} = ev) do
    %Session{session | corpo_id: ev.corpo_id}
  end
end
