defmodule OrdoWeb.EmployeeComponents do
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

  alias Phoenix.LiveView.JS
  # import OrdoWeb.Gettext
  import OrdoWeb.ViewHelpers
  # import OrdoWeb.CoreComponents

  attr :employee, :any, required: true

  def employee_image(assigns) do
    ~H"""
    <div class="relative inline-flex bg-violet-300 hover:border-2 hover:border-solid hover:border-gray-400 items-center justify-center w-10 h-10 overflow-hidden bg-gray-100 rounded-full dark:bg-gray-600">
      <span class="font-medium text-gray-600 dark:text-gray-300">
        <%= employee_initials(@employee) %>
      </span>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :employee, :any, required: true
  attr :tooltip, :boolean, default: false
  slot :action

  def employee_avatar(assigns) do
    ~H"""
    <div class="relative mr-1">
      <.link
        navigate={employee_path(@employee)}
        data-tooltip-target={"employee-avatar-#{@id}-#{@employee.id}"}
      >
        <.employee_image employee={@employee} />
      </.link>

      <%= if @action, do: render_slot(@action) %>
    </div>
    <%= if @tooltip do %>
      <div
        id={"employee-avatar-#{@id}-#{@employee.id}"}
        role="tooltip"
        class="absolute z-10 invisible  inline-block px-3 py-2 text-sm font-medium text-white transition-opacity duration-300 bg-gray-900 rounded-lg shadow-sm opacity-0 tooltip dark:bg-gray-700"
      >
        <%= employee_name!(@employee) %>

        <div class="tooltip-arrow" data-popper-arrow></div>
      </div>
    <% end %>
    """
  end

  attr :employee, :any, default: nil

  def employee_link(assigns) do
    ~H"""
    <.link
      class={[@employee && "text-purple-700 dark:text-purple-500"]}
      navigate={employee_path(@employee)}
    >
      <%= employee_name!(@employee) %>
    </.link>
    """
  end

  attr :on_click, JS
  attr :data_confirm, :string
  slot :inner_block, required: true

  def avatar_action(assigns) do
    ~H"""
    <.link
      class="top-0 left-7 absolute bg-gray-300 p-1 inline-flex items-center justify-center bg-gray-200 text-gray-800 rounded-full hover:text-white hover:bg-red-600 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-indigo-500"
      phx-click={@on_click}
      data-confirm={@data_confirm}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  attr :id, :string, required: true
  attr :on_click, JS, default: nil
  attr :tooltip, :string, default: nil

  def empty_avatar_action(assigns) do
    ~H"""
    <.link
      phx-click={@on_click}
      class="relative font-thin inline-flex items-center border-dashed hover:border-solid border-gray-300 border-2	justify-center w-10 h-10 overflow-hidden rounded-full dark:bg-gray-600"
      data-tooltip-target={"empty-avatar-action-#{@id}"}
    >
      &#10010;
    </.link>

    <%= if @tooltip do %>
      <div
        id={"empty-avatar-action-#{@id}"}
        role="tooltip"
        class="absolute z-10 invisible inline-block px-3 py-2 text-sm font-medium text-white transition-opacity duration-300 bg-gray-900 rounded-lg shadow-sm opacity-0 tooltip dark:bg-gray-700"
      >
        <%= @tooltip %>
        <div class="tooltip-arrow" data-popper-arrow></div>
      </div>
    <% end %>
    """
  end

  def employee_path(nil), do: nil

  def employee_path(employee) do
    ~p"/app/#{employee.corpo_id}/people/#{employee.id}"
  end
end
