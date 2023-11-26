defmodule Ordo.Notifications.Projectors.Notification do
  use Commanded.Projections.Ecto,
    application: Ordo.App,
    repo: Ordo.Repo,
    name: __MODULE__,
    consistency: :strong

  import Ecto.Query

  alias Ordo.Notifications
  alias Ordo.Notifications.Projections.Notification

  alias Ordo.Notifications.Events.NotificationCreated
  alias Ordo.Notifications.Events.NotificationRead

  project(
    %NotificationCreated{} = ev,
    metadata,
    fn multi ->
      changeset =
        %Notification{
          id: ev.notification_id,
          notified_id: ev.notified_id,
          notifier_id: ev.notifier_id,
          type: ev.type,
          inserted_at: DateTime.truncate(metadata.created_at, :second)
        }
        |> Notification.changeset(ev.payload)

      multi
      |> Ecto.Multi.insert(:notification, changeset)
      |> Ecto.Multi.run(:pubsub, fn repo, %{notification: notification} ->
        # I don't think it belongs there, bvut maybe?
        # PubSub belongs to Read layer, maybe it's a good place after all
        # Definitely makes things easier now
        notification
        |> repo.preload([:notified, :notifier, :employee, :task, :list])
        |> Notifications.publish_employee_notification()

        {:ok, true}
      end)
    end
  )

  project(
    %NotificationRead{notification_id: notification_id},
    _metadata,
    fn multi ->
      multi
      |> Ecto.Multi.update_all(:read, where(Notification, id: ^notification_id),
        set: [read: true]
      )
    end
  )
end
