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

  scope "/", OrdoWeb do
    pipe_through [:browser]

    get "/", PageController, :home

    scope "/auth", Authentication do
      delete "/log_out", SessionController, :delete
    end

    scope "/auth", Authentication do
      pipe_through([:redirect_if_actor_is_authenticated])

      live_session :redirect_if_actor_is_authenticated,
        on_mount: [{OrdoWeb.ActorAuth, :redirect_if_actor_is_authenticated}] do
        live "/register", RegisterLive, :new
        live "/sign_in", SignInLive, :new
      end

      post "/log_in", SessionController, :create
    end
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
