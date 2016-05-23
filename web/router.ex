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
    resources "/connections", ConnectionController

    # TODO: delete the following route entries
    resources "/memberships", MembershipController
    resources "/connections", ConnectionController do
      resources "/memberships", MembershipController
    end

    resources "/users", UserController do
      resources "/emails", EmailController
      resources "/groups", GroupController
    end
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/follow_back/:id", UserController, :follow_back
  end

  # Other scopes may use custom stacks.
  # scope "/api", Vutuv do
  #   pipe_through :api
  # end
end
