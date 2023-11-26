defmodule OrdoWeb.Notifications.EmployeeBellLive do
  use OrdoWeb, :live_view

  alias Ordo.Notifications
  import OrdoWeb.NotificationComponents

  on_mount {OrdoWeb.ActorAuth, :ensure_corpo_actor}

  @impl true
  def mount(_params, _session, socket) do
    Notifications.subscribe_to_employee_notifications(socket.assigns.actor)

    {:ok,
     socket |> stream(:notifications, Notifications.list_notifications(socket.assigns.actor)),
     layout: false}
  end

  @impl true
  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div
      class="z-20 z-50 hidden max-w-sm my-4 overflow-hidden text-base list-none bg-white divide-y divide-gray-100 rounded shadow-lg dark:divide-gray-600 dark:bg-gray-700"
      id="notification-dropdown"
    >
      <div class="block px-4 py-2 text-base font-medium text-center text-gray-700 bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
        Notifications
      </div>
      <div id="notification-list" class="max-h-96 overflow-y-scroll" phx-update="stream">
        <.notification_item
          :for={{dom_id, notification} <- @streams.notifications}
          id={dom_id}
          notification={notification}
        />
      </div>
      <a
        phx-click={JS.push("read_all")}
        class="block py-2 text-base font-normal text-center text-gray-900 bg-gray-50 hover:bg-gray-100 dark:bg-gray-700 dark:text-white dark:hover:underline"
      >
        <div class="inline-flex items-center ">
          <svg
            class="w-5 h-5 mr-2"
            fill="currentColor"
            viewBox="0 0 20 20"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path d="M10 12a2 2 0 100-4 2 2 0 000 4z"></path>
            <path
              fill-rule="evenodd"
              d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z"
              clip-rule="evenodd"
            >
            </path>
          </svg>
          <%= gettext("notifications.mark_as_read") %>
        </div>
      </a>
    </div>
    """
  end

  @impl true

  def handle_info(%Ordo.Notifications.Projections.Notification{} = notification, socket) do
    {:noreply, stream_insert(socket, notification, at: 0)}
  end

  @impl true
  def handle_event("read_all", _, socket) do
    # notifications = socket.assigns.notifications
    # Ordo.Notifications.mark_as_read(socket.assigns.actor, notifications)

    # notifications = Enum.map(notifications, &Map.put(&1, :read, true))

    # {:noreply, assign(socket, :notifications, notifications)}
    {:noreply, socket}
  end
end
