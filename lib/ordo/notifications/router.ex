defmodule Ordo.Notifications.Router do
  use Commanded.Commands.Router

  dispatch(
    [
      Ordo.Notifications.Commands.CreateEmployeeNotification,
      Ordo.Notifications.Commands.MarkNotificationAsRead
    ],
    to: Ordo.Notifications.Aggregates.Notification,
    identity: :notification_id
  )
end
