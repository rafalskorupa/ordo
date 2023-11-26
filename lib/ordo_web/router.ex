defmodule OrdoWeb.Router do
  use OrdoWeb, :router

  import OrdoWeb.ActorAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {OrdoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_actor
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/app/:corpo_id", OrdoWeb do
    pipe_through [:browser]

    live_session :ensure_corpo_actor,
      on_mount: [
        {OrdoWeb.ActorAuth, :ensure_corpo_actor}
      ] do
      live "/", App.DashboardLive, :index

      scope "/people", People do
        live "/", EmployeeLive.Index, :index
        live "/new", EmployeeLive.Index, :new
        live "/:id/edit", EmployeeLive.Index, :edit
        live "/:id/invite", EmployeeLive.Index, :invite

        live "/:id", EmployeeLive.Show, :show
        live "/:id/show/edit", EmployeeLive.Show, :edit
      end

      scope "/task_lists", ListLive do
        live "/", Index, :index
        live "/new", Index, :new
        live "/:id/edit", Index, :edit

        live "/:id", Show, :show
        live "/:id/show/edit", Show, :edit
      end
    end
  end

  scope "/", OrdoWeb do
    pipe_through [:browser]

    get "/", PageController, :home

    scope "/auth", Authentication do
      get "/log_out", SessionController, :delete
      delete "/log_out", SessionController, :delete
    end
  end

  scope "/", OrdoWeb do
    pipe_through [:browser, :require_authenticated_actor]

    scope "/auth", Authentication do
      live_session :require_authenticated_actor,
        on_mount: [{OrdoWeb.ActorAuth, :ensure_authenticated}] do
        live "/corpos/new", CorposLive, :new
        live "/corpos", CorposLive, :index
        live "/invitations/:invitation_id", ConfirmInvitationLive, :show
      end
    end
  end

  scope "/auth", OrdoWeb.Authentication do
    pipe_through([:browser, :redirect_if_actor_is_authenticated])

    live_session :redirect_if_actor_is_authenticated,
      on_mount: [{OrdoWeb.ActorAuth, :redirect_if_actor_is_authenticated}] do
      live "/register", RegisterLive, :new
      live "/sign_in", SignInLive, :new
    end

    post "/log_in", SessionController, :create
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ordo, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: OrdoWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
