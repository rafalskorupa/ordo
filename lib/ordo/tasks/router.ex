defmodule Ordo.Tasks.Router do
  use Commanded.Commands.Router

  dispatch(
    [
      Ordo.Tasks.Commands.CreateList,
      Ordo.Tasks.Commands.UpdateList,
      Ordo.Tasks.Commands.DeleteList
    ],
    to: Ordo.Tasks.Aggregates.List,
    identity: :list_id
  )
end
