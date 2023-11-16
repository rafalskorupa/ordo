defmodule Ordo.App do
  use Commanded.Application,
    otp_app: :ordo,
    event_store: [
      adapter: Commanded.EventStore.Adapters.EventStore,
      event_store: Ordo.EventStore
    ]

  router(Ordo.Authentication.Router)
end
