defmodule Ordo.Notifications.Aggregates.Notification do
  defstruct [:notification_id, :notified_id, :read, :payload, :type]

  alias Commanded.Aggregate.Multi

  alias Ordo.Notifications.Commands.CreateEmployeeNotification
  alias Ordo.Notifications.Commands.MarkNotificationAsRead

  alias Ordo.Notifications.Events.NotificationCreated
  alias Ordo.Notifications.Events.NotificationRead

  def create_notification(%__MODULE__{}, %CreateEmployeeNotification{} = command) do
    %{notifier_id: notifier_id, notified_id: notified_id} = command

    if notifier_id != notified_id do
      %NotificationCreated{
        notification_id: command.notification_id,
        notified_id: command.notified_id,
        notifier_id: command.notifier_id,
        payload: command.payload,
        type: command.type
      }
    else
      :ok
    end
  end

  def execute(%__MODULE__{} = notification, %CreateEmployeeNotification{} = command) do
    notification
    |> Multi.new()
    |> Multi.execute(&create_notification(&1, command))
  end

  def execute(
        %__MODULE__{notification_id: notification_id, notified_id: notified_id} = aggregate,
        %MarkNotificationAsRead{actor: %{employee: %{id: notified_id}} = actor}
      ) do
    if aggregate.read do
      :ok
    else
      %NotificationRead{
        notification_id: notification_id,
        actor: Ordo.Actor.serialize(actor)
      }
    end
  end

  def apply(%__MODULE__{}, %NotificationCreated{} = ev) do
    %__MODULE__{
      notification_id: ev.notification_id,
      notified_id: ev.notified_id,
      payload: ev.payload,
      type: ev.type,
      read: false
    }
  end

  def apply(%__MODULE__{} = notification, %NotificationRead{}) do
    %__MODULE__{notification | read: true}
  end
end
