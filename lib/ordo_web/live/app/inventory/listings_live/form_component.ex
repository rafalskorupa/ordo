defmodule OrdoWeb.App.Inventory.ListingsLive.FormComponent.FormComponent do
  use OrdoWeb, :live_component

  alias Ordo.Inventory

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.drawer label={@label} back={@patch}>
        <.simple_form
          for={@form}
          id="listing-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <div class="space-y-4">
            <.input
              field={@form[:name]}
              type="text"
              label="Name"
              class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500"
              placeholder="Type product name"
            />
            <.input
              field={@form[:price]}
              type="number"
              step="1"
              label="Price (in cents)"
              class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500"
              placeholder="99"
            />
            <%= if @listing == :new do %>
              <.input field={@form[:total]} type="number" step="1" label="Available" />
            <% end %>

            <%= if @listing != :new && !@listing.public do %>
              <button
                phx-click={JS.push("publish", value: %{id: @listing.id})}
                data-confirm="Are you sure to make listing public?"
                type="button"
                class="w-full justify-center text-purple-600 inline-flex items-center hover:text-white border border-purple-600 hover:bg-purple-600 focus:ring-4 focus:outline-none focus:ring-purple-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:border-purple-500 dark:text-purple-500 dark:hover:text-white dark:hover:bg-purple-600 dark:focus:ring-purple-900"
              >
                Publish
              </button>
            <% else %>
              <button
                type="button"
                class="w-full justify-center text-purple-600 inline-flex items-center hover:text-white border border-purple-600 hover:bg-purple-600 focus:ring-4 focus:outline-none focus:ring-purple-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:border-purple-500 dark:text-purple-500 dark:hover:text-white dark:hover:bg-purple-600 dark:focus:ring-purple-900"
              >
                See in Marketplace
              </button>
            <% end %>
          </div>

          <div class="bottom-0 left-0 flex justify-center w-full pb-4 mt-4 space-x-4 sm:absolute sm:px-4 sm:mt-0">
            <.button
              class="w-full justify-center text-white bg-primary-700 hover:bg-primary-800 focus:ring-4 focus:outline-none focus:ring-primary-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-primary-600 dark:hover:bg-primary-700 dark:focus:ring-primary-800"
              phx-disable-with="Saving..."
            >
              Save Listing
            </.button>
            <button
              type="button"
              class="w-full justify-center text-red-600 inline-flex items-center hover:text-white border border-red-600 hover:bg-red-600 focus:ring-4 focus:outline-none focus:ring-red-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:border-red-500 dark:text-red-500 dark:hover:text-white dark:hover:bg-red-600 dark:focus:ring-red-900"
            >
              <svg
                aria-hidden="true"
                class="w-5 h-5 mr-1 -ml-1"
                fill="currentColor"
                viewBox="0 0 20 20"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  fill-rule="evenodd"
                  d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z"
                  clip-rule="evenodd"
                >
                </path>
              </svg>
              Delete
            </button>
          </div>
        </.simple_form>
      </.drawer>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"create_listing" => listing_params}, socket) do
    changeset =
      form_changeset(socket.assigns.listing, listing_params) |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"create_listing" => listing_params}, socket) do
    case Inventory.create_listing(socket.assigns.actor, listing_params) do
      {:ok, listing} ->
        notify_parent({:saved, listing})

        {:noreply,
         socket
         |> put_flash(:info, "Listing created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl true
  def update(%{listing: listing} = assigns, socket) do
    changeset = form_changeset(listing, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @spec form_changeset(
          :new
          | %{
              :__struct__ =>
                Ordo.Listings.Commands.UpdateListing | Ordo.Listings.Projections.Listing,
              optional(any()) => any()
            },
          any()
        ) :: any()
  def form_changeset(:new, params) do
    Inventory.create_listing_changeset(params)
  end

  def form_changeset(listing, params) do
    Inventory.update_listing_changeset(listing, params)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
