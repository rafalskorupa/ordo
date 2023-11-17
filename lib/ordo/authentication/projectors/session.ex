defmodule Ordo.Authentication.Projectors.Session do
  use Commanded.Projections.Ecto,
    application: Ordo.App,
    repo: Ordo.Repo,
    name: "session-projection",
    consistency: :strong

  alias Ordo.People.Projections.Employee
  alias Ordo.Authentication.Projections.Session
  alias Ordo.Authentication.Events.SessionCreated
  alias Ordo.Authentication.Events.SessionCorpoSet

  project(
    %SessionCreated{session_id: session_id, account_id: account_id},
    _metadata,
    fn multi ->
      Ecto.Multi.insert(multi, :session, %Session{
        id: session_id,
        account_id: account_id
      })
    end
  )

  project(
    %SessionCorpoSet{session_id: session_id, corpo_id: corpo_id},
    _metadata,
    fn multi ->
      with %{} = session <- Ordo.Repo.get(Session, session_id),
           %{} = employee <-
             Ordo.Repo.get_by(Employee, account_id: session.account_id, corpo_id: corpo_id) do
        changeset =
          Ecto.Changeset.change(session, %{employee_id: employee.id, corpo_id: corpo_id})

        Ecto.Multi.update(multi, :session, changeset)
      else
        nil -> multi
      end
    end
  )
end
