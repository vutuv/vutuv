defmodule Vutuv.Router do
  use Vutuv.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Vutuv.Auth, repo: Vutuv.Repo
  end

  pipeline :user_pipe do
    plug Vutuv.UserResolveSlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Vutuv do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    # TODO: delete the following route entries
    resources "/memberships", MembershipController
    resources "/connections", ConnectionController, only: [:new, :create, :show, :delete, :index] do
      resources "/memberships", MembershipController, only: [:new, :create, :show, :delete, :index]
    end

    resources "/users", UserController, param: "slug" do
      pipe_through :user_pipe
      resources "/emails", EmailController
      resources "/slugs", SlugController, only: [:index, :new, :create, :show, :update]
      resources "/groups", GroupController
      resources "/followers", FollowerController, only: [:index]
      resources "/followees", FolloweeController, only: [:index]
      resources "/skills", UserSkillController, only: [:new, :create, :show, :delete, :index]
      resources "/endorsements", EndorsementController, only: [:create, :delete]
      resources "/phonenumbers", PhoneNumberController
      resources "/dates", UserDateController
      resources "/links", UserUrlController
      resources "/socialmedia", SocialMediaAccountController
      resources "/workexperience", WorkExperienceController
      resources "/addresses", AddressController
    end


    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/magic/:magiclink", SessionController, :show
    get "/magicdelete/:magiclink", UserController, :magicdelete
    get "/follow_back/:id", UserController, :follow_back
  end

  scope "/admin", as: :admin do
    pipe_through :browser
    resources "/", Vutuv.Admin.AdminController, only: [:index]
    post "/slugs", Vutuv.Admin.SlugController, :update
    post "/users", Vutuv.Admin.UserController, :update
  end

  # Other scopes may use custom stacks.
  # scope "/api", Vutuv do
  #   pipe_through :api
  # end
end
