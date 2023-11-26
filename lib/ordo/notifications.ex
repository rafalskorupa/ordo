defmodule Ordo.Notifications do
  alias Ordo.Repo

  alias Ordo.Notifications.Projections.Notification

  import Ecto.Query

  alias Phoenix.PubSub

  alias Ordo.Notifications.Commands.CreateEmployeeNotification

  @task_events [
    Ordo.Tasks.Events.EmployeeAssignedToTask,
    Ordo.Tasks.Events.EmployeeDeassignedFromTask,
    Ordo.Tasks.Events.TaskCompleted,
    Ordo.Tasks.Events.TaskArchived,
    Ordo.Tasks.Events.TaskCreated
  ]

  @doc """
  Finds watchers for resource on given event and creates a notification for them
  """
  def send_to_watchers(%module{} = event) when module in @task_events do
    event
    |> task_watchers_ids()
    |> Enum.each(fn watcher_id ->
      watcher_id
      |> CreateEmployeeNotification.build!(event)
      |> Ordo.App.dispatch()
    end)

    :ok
  end

  @spec task_watchers_ids(any()) :: list(String.t())
  def task_watchers_ids(%{task_id: task_id} = event) do
    task_id
    |> Ordo.Tasks.task_assignees()
    |> Enum.map(& &1.employee_id)
    |> Enum.concat(directly_interested(event))
    |> Enum.uniq()
  end

  @spec directly_interested(any()) :: list(String.t())
  defp directly_interested(%{employee_id: employee_id}), do: [employee_id]
  defp directly_interested(_), do: []

  # Queries

  @spec get_notification!(Ordo.Actor.t(), String.t()) :: Notification.t()
  def get_notification!(actor, notification_id) do
    Notification
    |> actor_scope(actor)
    |> Repo.get!(notification_id)
    |> Repo.preload([:notifier, :task])
  end

  @spec list_notifications(Ordo.Actor.t()) :: list(Notification.t())
  @spec list_notifications(Ordo.Actor.t(), map()) :: list(Notification.t())
  def list_notifications(actor, opts \\ %{}) do
    limit = Map.get(opts, :limit, 10)

    Notification
    |> actor_scope(actor)
    |> limit(^limit)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
    |> Repo.preload([:notifier, :employee, :task])
  end

  @doc """
  Creates a PubSub connection for notifications in Employee Info
  """
  def subscribe_to_employee_notifications(%Ordo.Actor{employee: %{id: employee_id}}) do
    PubSub.subscribe(Ordo.PubSub, employee_channel(employee_id))
  end

  @doc """
  Publish Notification in PubSub in employee channel
  """
  @spec publish_employee_notification(Notification.t()) :: :ok
  def publish_employee_notification(notification) do
    PubSub.broadcast(
      Ordo.PubSub,
      employee_channel(notification.notified_id),
      notification
    )
  end

  defp actor_scope(query, %Ordo.Actor{employee: %{id: notified_id}}) do
    where(query, notified_id: ^notified_id)
  end

  defp employee_channel(employee_id) do
    "notifications-employee:#{employee_id}"
  end
end
