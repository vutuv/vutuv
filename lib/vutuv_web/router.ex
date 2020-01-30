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
      put "/email_addresses/set_primary/:id", EmailAddressController, :set_primary
      resources "/email_notifications", EmailNotificationController
      resources "/followees", FolloweeController, only: [:index, :create, :delete]
      resources "/followers", FollowerController, only: [:index]
      resources "/passwords", PasswordController, only: [:new, :create]
      resources "/posts", PostController
      resources "/social_media_accounts", SocialMediaAccountController
      resources "/tags", UserTagController, only: [:index, :new, :create, :delete], as: :tag

      resources "/user_tag_endorsements", UserTagEndorsementController,
        only: [:create, :delete],
        as: :tag_endorsement

      resources "/work_experiences", WorkExperienceController
    end

    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/verifications", VerificationController, only: [:new, :create]
    post "/verifications/send_code", VerificationController, :send_code

    resources "/password_resets", PasswordResetController,
      only: [:new, :create, :edit, :update],
      singleton: true

    get "/password_resets/new_request", PasswordResetController, :new_request
    post "/password_resets/create_request", PasswordResetController, :create_request
  end

  scope "/api/v2", VutuvWeb.Api, as: :api do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit], param: "slug" do
      resources "/addresses", AddressController, except: [:new, :edit]
      resources "/email_addresses", EmailAddressController, except: [:new, :edit]
      put "/email_addresses/set_primary/:id", EmailAddressController, :set_primary
      resources "/followees", FolloweeController, only: [:index, :create, :delete]
      resources "/followers", FollowerController, only: [:index]
      resources "/passwords", PasswordController, only: [:create]
      resources "/posts", PostController, except: [:new, :edit]
      resources "/social_media_accounts", SocialMediaAccountController, except: [:new, :edit]
      resources "/tags", UserTagController, only: [:index, :create, :delete], as: :tag

      resources "/user_tag_endorsements", UserTagEndorsementController,
        only: [:create, :delete],
        as: :tag_endorsement

      get "/vcard", VcardController, :vcard
      resources "/work_experiences", WorkExperienceController, except: [:new, :edit]
    end

    post "/sessions", SessionController, :create
    post "/verifications", VerificationController, :create
    post "/verifications/send_code", VerificationController, :send_code

    resources "/password_resets", PasswordResetController,
      only: [:create, :update],
      singleton: true

    get "/password_resets/new_request", PasswordResetController, :new_request
    post "/password_resets/create_request", PasswordResetController, :create_request
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end
end
