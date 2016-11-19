defmodule Vutuv.FollowerController do
  use Vutuv.Web, :controller

  def index(conn, _params) do
  	user = 
			conn.assigns[:user]
			|> Repo.preload([:followers, follower_connections: [:follower]])
    render(conn, "index.html", user: user)
  end
end
