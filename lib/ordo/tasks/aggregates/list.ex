defmodule Ordo.Tasks.Aggregates.List do
  defstruct [:list_id, :corpo_id, :name, :deleted]

  alias Commanded.Aggregate.Multi

  alias Ordo.Tasks.Aggregates.List

  alias Ordo.Tasks.Commands.CreateList
  alias Ordo.Tasks.Commands.DeleteList
  alias Ordo.Tasks.Commands.UpdateList
  alias Ordo.Tasks.Commands.VerifyList

  alias Ordo.Tasks.Events.ListCreated
  alias Ordo.Tasks.Events.ListDeleted
  alias Ordo.Tasks.Events.ListNameChanged

  def verify_list!(%List{corpo_id: corpo_id, deleted: false}, %Ordo.Actor{corpo: %{id: corpo_id}}),
    do: :ok

  def verify_list!(_, _), do: {:error, :list_not_found}

  def create_list(%List{list_id: nil}, list_id, %Ordo.Actor{} = actor) do
    %ListCreated{
      list_id: list_id,
      corpo_id: actor.corpo.id,
      actor: Ordo.Actor.serialize(actor)
    }
  end

  def update_name(%List{name: name}, %{name: name}), do: :ok

  def update_name(%List{list_id: list_id, corpo_id: corpo_id}, %{name: name, actor: actor}) do
    %ListNameChanged{
      list_id: list_id,
      corpo_id: corpo_id,
      name: name,
      actor: Ordo.Actor.serialize(actor)
    }
  end

  def delete_list(%List{list_id: list_id, corpo_id: corpo_id}, actor) do
    %ListDeleted{
      list_id: list_id,
      corpo_id: corpo_id,
      actor: Ordo.Actor.serialize(actor)
    }
  end

  def execute(%List{} = list, %VerifyList{actor: actor}) do
    verify_list!(list, actor)
  end

  def execute(%List{} = aggregate, %CreateList{} = command) do
    CreateList.validate!(command)

    aggregate
    |> Multi.new()
    |> Multi.execute(fn list -> create_list(list, command.list_id, command.actor) end)
    |> Multi.execute(fn list -> update_name(list, command) end)
  end

  def execute(%List{} = aggregate, %UpdateList{} = command) do
    UpdateList.validate!(command)

    aggregate
    |> Multi.new()
    |> Multi.execute(fn list -> verify_list!(list, command.actor) end)
    |> Multi.execute(fn list -> update_name(list, command) end)
  end

  def execute(%List{} = aggregate, %DeleteList{} = command) do
    DeleteList.validate!(command)

    aggregate
    |> Multi.new()
    |> Multi.execute(fn list -> verify_list!(list, command.actor) end)
    |> Multi.execute(fn list -> delete_list(list, command.actor) end)
  end

  def apply(%List{}, %ListCreated{} = ev) do
    %List{
      list_id: ev.list_id,
      corpo_id: ev.corpo_id,
      deleted: false
    }
  end

  def apply(%List{} = aggregate, %ListNameChanged{name: name}) do
    %List{aggregate | name: name}
  end

  def apply(%List{} = aggregate, %ListDeleted{}) do
    %List{aggregate | deleted: true}
  end
end
