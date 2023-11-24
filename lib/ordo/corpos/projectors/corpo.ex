defmodule Ordo.Corpos.Projectors.Corpo do
  use Commanded.Projections.Ecto,
    application: Ordo.App,
    repo: Ordo.Repo,
    name: "corpo-projection",
    consistency: :strong

  alias Ordo.Corpos.Projections.Corpo

  alias Ordo.Corpos.Events.CorpoCreated

  project(
    %CorpoCreated{corpo_id: corpo_id, name: name},
    _metadata,
    fn multi ->
      Ecto.Multi.insert(multi, :corpo, %Corpo{
        id: corpo_id,
        name: name
      })
    end
  )
end
