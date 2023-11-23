defmodule Ordo.Tasks.Projectors.List do
  use Commanded.Projections.Ecto,
    application: Ordo.App,
    repo: Ordo.Repo,
    name: "task_list-projection",
    consistency: :strong

  import Ecto.Query

  alias Ordo.Tasks.Projections.List
  alias Ordo.Tasks.Events.ListCreated
  alias Ordo.Tasks.Events.ListNameChanged
  alias Ordo.Tasks.Events.ListDeleted

  project(
    %ListCreated{corpo_id: corpo_id, list_id: list_id},
    _metadata,
    fn multi ->
      Ecto.Multi.insert(multi, :list, %List{
        id: list_id,
        corpo_id: corpo_id
      })
    end
  )

  project(
    %ListNameChanged{list_id: list_id, name: name},
    _metadata,
    fn multi ->
      query = where(List, id: ^list_id)

      Ecto.Multi.update_all(multi, :update_name, query, set: [name: name])
    end
  )

  project(
    %ListDeleted{list_id: list_id},
    _metadata,
    fn multi ->
      query = where(List, id: ^list_id)

      Ecto.Multi.delete_all(multi, :delete_list, query)
    end
  )
end
