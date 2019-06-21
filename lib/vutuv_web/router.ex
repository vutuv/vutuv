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

  pipeline :api do
    plug :accepts, ["json"]
    plug Phauxth.AuthenticateToken
  end

  scope "/", VutuvWeb do
    pipe_through :browser

    get "/", UserController, :new

    resources "/users", UserController, except: [:new] do
      resources "/email_addresses", EmailAddressController
    end

    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/confirms", ConfirmController, only: [:new, :create]
    resources "/password_resets", PasswordResetController, only: [:new, :create, :edit, :update]
    get "/password_resets/new_request", PasswordResetController, :new_request
    post "/password_resets/create_request", PasswordResetController, :create_request
  end

  scope "/api/v1", VutuvWeb.Api, as: :api do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit] do
      resources "/email_addresses", EmailAddressController, except: [:new, :edit]
    end

    post "/sessions", SessionController, :create
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end
end
