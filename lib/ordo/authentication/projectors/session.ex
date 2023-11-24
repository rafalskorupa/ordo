defmodule Ordo.Authentication.Projectors.Session do
  use Commanded.Projections.Ecto,
    application: Ordo.App,
    repo: Ordo.Repo,
    name: "session-projection",
    consistency: :strong

  alias Ordo.Authentication.Projections.Session

  alias Ordo.Authentication.Events.SessionCreated

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
end
