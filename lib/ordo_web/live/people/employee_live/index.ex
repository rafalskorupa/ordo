defmodule OrdoWeb.People.EmployeeLive.Index do
  use OrdoWeb, :live_view

  alias Ordo.People
  alias Ordo.People.Projections.Employee

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def styled_table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="overflow-x-auto">
      <div class="inline-block min-w-full align-middle">
        <div class="overflow-hidden shadow">
          <table class="min-w-full divide-y divide-gray-200 table-fixed dark:divide-gray-600">
            <thead class="bg-gray-100 dark:bg-gray-700">
              <tr>
                <th
                  :for={col <- @col}
                  scope="col"
                  class="p-4 text-xs font-medium text-left text-gray-500 uppercase dark:text-gray-400"
                >
                  <%= col[:label] %>
                </th>
                <th :if={@action != []} class="relative p-0 pb-4">
                  <span class="sr-only"><%= gettext("Actions") %></span>
                </th>
              </tr>
            </thead>
            <tbody
              id={@id}
              phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
              class="bg-white divide-y divide-gray-200 dark:bg-gray-800 dark:divide-gray-700"
            >
              <tr
                :for={row <- @rows}
                id={@row_id && @row_id.(row)}
                class="hover:bg-gray-100 dark:hover:bg-gray-700"
              >
                <td
                  :for={{col, _i} <- Enum.with_index(@col)}
                  phx-click={@row_click && @row_click.(row)}
                  class={[
                    "p-4 text-base font-medium text-gray-900 whitespace-nowrap dark:text-white",
                    @row_click && "hover:cursor-pointer"
                  ]}
                >
                  <%= render_slot(col, @row_item.(row)) %>
                </td>
                <td :if={@action != []} class="relative w-14 p-0">
                  <div class="relative whitespace-nowrap py-4 text-right text-sm font-medium">
                    <span class="absolute -inset-y-px -right-4 left-0 group-hover:bg-zinc-50 sm:rounded-r-xl" />
                    <span
                      :for={action <- @action}
                      class="relative ml-4 font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                    >
                      <%= render_slot(action, @row_item.(row)) %>
                    </span>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    actor = socket.assigns.actor

    {:ok, stream(socket, :employees, People.list_employees(actor))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    actor = socket.assigns.actor

    socket
    |> assign(:page_title, "Edit Employee")
    |> assign(:employee, People.get_employee!(actor, id))
  end

  defp apply_action(socket, :invite, %{"id" => id}) do
    actor = socket.assigns.actor

    socket
    |> assign(:page_title, "Invite Employee")
    |> assign(:employee, People.get_employee!(actor, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Employee")
    |> assign(:employee, %Employee{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Employees")
    |> assign(:employee, nil)
  end

  @impl true
  def handle_info({OrdoWeb.People.EmployeeLive.FormComponent, {:saved, employee}}, socket) do
    {:noreply, stream_insert(socket, :employees, employee)}
  end

  def handle_info({OrdoWeb.People.EmployeeLive.InvitationComponent, {:invited, employee}}, socket) do
    {:noreply, stream_insert(socket, :employees, employee)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    employee = People.get_employee!(socket.assigns.actor, id)
    {:ok, _} = People.delete_employee(socket.assigns.actor, employee)

    {:noreply, stream_delete(socket, :employees, employee)}
  end
end
