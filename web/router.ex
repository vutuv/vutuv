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

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Vutuv do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    resources "/skills", SkillController

    # TODO: delete the following route entries
    resources "/memberships", MembershipController
    resources "/connections", ConnectionController, only: [:new, :create, :show, :delete, :index] do
      resources "/memberships", MembershipController, only: [:new, :create, :show, :delete, :index]
    end

    resources "/users", UserController do
      resources "/emails", EmailController
      resources "/slugs", SlugController
      resources "/groups", GroupController
      resources "/followers", FollowerController, only: [:index]
      resources "/followees", FolloweeController, only: [:index]
      resources "/userskills", UserSkillController, only: [:new, :create, :show, :delete, :index]
      resources "/endorsements", EndorsementController, only: [:create, :delete]
    end
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/magic/:magiclink", SessionController, :show
    get "/follow_back/:id", UserController, :follow_back
  end

  # Other scopes may use custom stacks.
  # scope "/api", Vutuv do
  #   pipe_through :api
  # end
end
