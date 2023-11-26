defmodule OrdoWeb.NotificationComponents do
  @moduledoc """
  Provides core UI components.

  At first glance, this module may seem daunting, but its goal is to provide
  core building blocks for your application, such as modals, tables, and
  forms. The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The default components use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn
  how to customize them or feel free to swap in another framework altogether.

  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: OrdoWeb.Endpoint,
    router: OrdoWeb.Router,
    statics: OrdoWeb.static_paths()

  import OrdoWeb.EmployeeComponents
  import OrdoWeb.TasksComponents

  attr :id, :string, required: true
  attr :notification, :any, required: true

  def notification_item(assigns) do
    ~H"""
    <div
      id={"notification-#{@id}"}
      href="#"
      class={[
        "flex px-4 py-3 font-medium border-b hover:bg-gray-100 dark:hover:bg-gray-600 dark:border-gray-600"
      ]}
    >
      <div class="flex-shrink-0">
        <.employee_image employee={@notification.notifier} />
      </div>
      <div class="w-full pl-3">
        <div class={[
          !@notification.read && "font-medium",
          "font-light text-gray-700 text-sm mb-1.5 dark:text-gray-400"
        ]}>
          <.notification_message notification={@notification} />
        </div>
        <div class={[
          !@notification.read && "font-medium",
          "text-xs font-light text-purple-700 dark:text-purple-400"
        ]}>
          <%= Calendar.strftime(@notification.inserted_at, "%A, %H:%M") %>
        </div>
      </div>
    </div>
    """
  end

  attr :notification, :any, required: true

  def notification_message(%{notification: %{type: "assigned_to_task"}} = assigns) do
    ~H"""
    <.employee_link employee={@notification.notifier} /> assigned
    <.employee_in_notification notification={@notification} /> to
    <.task_link task={@notification.task} />
    """
  end

  def notification_message(%{notification: %{type: "unassigned_from_task"}} = assigns) do
    ~H"""
    <.employee_link employee={@notification.notifier} /> unnassigned
    <.employee_in_notification notification={@notification} /> from
    <.task_link task={@notification.task} />
    """
  end

  def notification_message(%{notification: %{type: "completed_task"}} = assigns) do
    ~H"""
    <.employee_link employee={@notification.notifier} /> completed
    <.task_link task={@notification.task} />
    """
  end

  def notification_message(%{notification: %{type: "archived_task"}} = assigns) do
    ~H"""
    <.employee_link employee={@notification.notifier} /> archived
    <.task_link task={@notification.task} />
    """
  end

  def notification_message(assigns) do
    ~H"""
    <%= @notification.type %>
    """
  end

  attr :notification, :any, required: true

  def employee_in_notification(%{notification: notification} = assigns) do
    if notification.employee_id == notification.notified_id do
      ~H"""
      you
      """
    else
      ~H"""
      <.employee_link employee={@notification.employee} />
      """
    end
  end
end
