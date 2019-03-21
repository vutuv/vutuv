defmodule VutuvWeb.Router do
  use VutuvWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phauxth.Authenticate
  end

  scope "/", VutuvWeb do
    pipe_through :browser

    get "/", UserController, :new
    resources "/users", UserController, except: [:new]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/confirm", ConfirmController, :index
    resources "/password_resets", PasswordResetController, only: [:new, :create]
    get "/password_resets/edit", PasswordResetController, :edit
    put "/password_resets/update", PasswordResetController, :update
    resources "/email_addresses", EmailAddressController
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end
end
