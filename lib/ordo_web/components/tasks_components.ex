defmodule OrdoWeb.TasksComponents do
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

  import OrdoWeb.ViewHelpers

  attr :task, :any, default: nil

  def task_link(assigns) do
    ~H"""
    <.link navigate={task_path(@task)} class={[@task && "text-purple-700 dark:text-purple-500"]}>
      <%= task_name!(@task) %>
    </.link>
    """
  end

  def task_path(nil), do: nil

  def task_path(task) do
    ~p"/app/#{task.corpo_id}/task_lists/#{task.list_id}"
  end
end
