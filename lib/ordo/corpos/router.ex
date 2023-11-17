defmodule Ordo.Corpos.Router do
  use Commanded.Commands.Router

  dispatch(
    [
      Ordo.Corpos.Commands.CreateCorpo
    ],
    to: Ordo.Corpos.Aggregates.Corpo,
    identity: :corpo_id
  )
end
