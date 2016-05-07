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
    resources "/groups", GroupController
    resources "/users", UserController do
      resources "/emails", EmailController
    end
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Vutuv do
  #   pipe_through :api
  # end
end
