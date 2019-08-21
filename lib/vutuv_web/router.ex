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

    resources "/users", UserController, except: [:new], param: "slug" do
      resources "/addresses", AddressController
      resources "/email_addresses", EmailAddressController
      resources "/followers", FollowerController, only: [:index]
      resources "/leaders", LeaderController, only: [:index]
      resources "/posts", PostController
      resources "/social_media_accounts", SocialMediaAccountController
      resources "/work_experiences", WorkExperienceController
    end

    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/verifications", VerificationController, only: [:new, :create]
    post "/verifications/send_code", VerificationController, :send_code

    resources "/password_resets", PasswordResetController, only: [:new, :create], param: "slug"
    get "/password_resets/new_request", PasswordResetController, :new_request
    post "/password_resets/create_request", PasswordResetController, :create_request
    get "/password_resets/edit", PasswordResetController, :edit
    put "/password_resets/update", PasswordResetController, :update
  end

  scope "/api/v2", VutuvWeb.Api, as: :api do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit], param: "slug" do
      resources "/email_addresses", EmailAddressController, except: [:new, :edit]
      get "/vcard", VcardController, :vcard
    end

    post "/sessions", SessionController, :create
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end
end
