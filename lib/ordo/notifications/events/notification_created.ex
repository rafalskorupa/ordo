defmodule Ordo.Notifications.Events.NotificationCreated do
  @derive Jason.Encoder
  defstruct [:notification_id, :notified_id, :notifier_id, :type, :payload]
end
