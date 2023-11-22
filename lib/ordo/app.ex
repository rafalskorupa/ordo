defmodule Ordo.App do
  use Commanded.Application,
    otp_app: :ordo,
    event_store: [
      adapter: Commanded.EventStore.Adapters.EventStore,
      event_store: Ordo.EventStore
    ]

  router(Ordo.Authentication.Router)
  router(Ordo.Corpos.Router)
  router(Ordo.People.Router)
  router(Ordo.Invitations.Router)
end
