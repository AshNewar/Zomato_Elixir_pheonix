defmodule ZomatoWeb.Router do
  # alias ZomatoWeb.PageControllerLive
  use ZomatoWeb, :router

  import ZomatoWeb.Restraurents.RestraurentAuth

  import ZomatoWeb.Warehouse.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ZomatoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_restraurent
    plug :fetch_current_user
    plug ZomatoWeb.Plugs.SessionCart
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ZomatoWeb do
    pipe_through :browser

    live "/", PageControllerLive, :show
    live "/about", AboutLive, :show
    live "/error" , ErrorLive , :new
  end

  # Other scopes may use custom stacks.
  # scope "/api", ZomatoWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:zomato, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ZomatoWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/warehouse", ZomatoWeb.Warehouse, as: :warehouse do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ZomatoWeb.Warehouse.UserAuth, :redirect_if_user_is_authenticated}] do
      # live "/users/register", UserRegistrationLive, :new
      # live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/warehouse", ZomatoWeb.Warehouse, as: :warehouse do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ZomatoWeb.Warehouse.UserAuth, :ensure_authenticated}] do

      # Routes for /warehouse
      live "/users/details/:user_id" , UserAboutLive, :new
      live "/users/dashboard", UserDashLive, :new
      live "/users/success/:payment_id", SuccessLive, :new
      live "users/chat", MessageLive, :new
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      # Routes for /restraurents (under same scope)
      scope "/restraurents" do
        live "/details/:id", RestraurentAboutLive, :show
      end
    end
  end


  scope "/warehouse", ZomatoWeb.Warehouse, as: :warehouse do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{ZomatoWeb.Warehouse.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  ## Authentication routes

  scope "/restraurents", ZomatoWeb.Restraurents, as: :restraurents do
    pipe_through [:browser, :redirect_if_restraurent_is_authenticated]

    live_session :redirect_if_restraurent_is_authenticated,
      on_mount: [{ZomatoWeb.Restraurents.RestraurentAuth, :redirect_if_restraurent_is_authenticated}] do
      live "/new", RestraurentHomeLive, :new
      live "/register", RestraurentRegistrationLive, :new
      live "/log_in", RestraurentLoginLive, :new
      live "/reset_password", RestraurentForgotPasswordLive, :new
      live "/reset_password/:token", RestraurentResetPasswordLive, :edit
    end

    post "/restraurents/log_in", RestraurentSessionController, :create
  end

  scope "/restraurents", ZomatoWeb.Restraurents, as: :restraurents do
    pipe_through [:browser, :require_authenticated_restraurent]

    live_session :require_authenticated_restraurent,
      on_mount: [{ZomatoWeb.Restraurents.RestraurentAuth, :ensure_authenticated}] do
        live "/dashboard", RestraurentDashLive, :new
        live "/menu", RestraurentMenuLive, :new
        live "/profile", RestraurentProfileLive, :new
      live "/restraurents/settings", RestraurentSettingsLive, :edit
      live "/restraurents/settings/confirm_email/:token", RestraurentSettingsLive, :confirm_email
    end
  end

  scope "/restraurents", ZomatoWeb.Restraurents, as: :restraurents do
    pipe_through [:browser]

    delete "/restraurents/log_out", RestraurentSessionController, :delete

    live_session :current_restraurent,
      on_mount: [{ZomatoWeb.Restraurents.RestraurentAuth, :mount_current_restraurent}] do
      live "/restraurents/confirm/:token", RestraurentConfirmationLive, :edit
      live "/restraurents/confirm", RestraurentConfirmationInstructionsLive, :new
    end
  end
end
