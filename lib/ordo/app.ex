defmodule Ordo.App do
  use Commanded.Application,
    otp_app: :ordo,
    event_store: [
      adapter: Commanded.EventStore.Adapters.EventStore,
      event_store: Ordo.EventStore
    ]

  router(Ordo.Authentication.Router)
  router(Ordo.Corpos.Router)
  router(Ordo.Inventory.Router)
  router(Ordo.Invitations.Router)
  router(Ordo.Notifications.Router)
  router(Ordo.People.Router)
  router(Ordo.Tasks.Router)
end
