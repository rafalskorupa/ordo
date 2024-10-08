defmodule Ordo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      OrdoWeb.Telemetry,
      Ordo.Repo,
      {DNSCluster, query: Application.get_env(:ordo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Ordo.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Ordo.Finch},
      # Start a worker by calling: Ordo.Worker.start_link(arg)
      # {Ordo.Worker, arg},
      # Start to serve requests, typically the last entry
      OrdoWeb.Endpoint,
      Ordo.App,
      {Oban, Application.fetch_env!(:ordo, Oban)},

      # Supervise separately
      Ordo.Authentication.Projectors.Account,
      Ordo.Authentication.Projectors.Session,
      Ordo.Corpos.Projectors.Corpo,
      Ordo.People.Projectors.Employee,
      Ordo.People.Handlers.CreateOwnerEmployee,
      Ordo.Invitations.Projectors.Invitation,
      Ordo.Tasks.Projectors.List,
      Ordo.Tasks.Projectors.Task,
      Ordo.Tasks.Projectors.Assignee,
      Ordo.Notifications.Handlers.Task,
      Ordo.Notifications.Projectors.Notification,
      Ordo.Listings.Projectors.List
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ordo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OrdoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
