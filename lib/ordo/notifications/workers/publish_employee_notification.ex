defmodule Ordo.Notifications.Workers.PublishEmployeeNotification do
  use Oban.Worker

  def perform(%{
        args: %{
          "type" => type,
          "payload" => payload,
          "watcher_id" => notified_id,
          "notifier_id" => notifier_id
        }
      }) do
    command = %Ordo.Notifications.Commands.CreateEmployeeNotification{
      notification_id: Ecto.UUID.generate(),
      type: type,
      notified_id: notified_id,
      notifier_id: notifier_id,
      payload: payload
    }

    Ordo.App.dispatch(command)
  end
end
