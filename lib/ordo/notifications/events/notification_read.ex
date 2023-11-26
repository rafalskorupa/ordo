defmodule Ordo.Notifications.Events.NotificationRead do
  @derive Jason.Encoder
  defstruct [:notification_id, :actor]
end
