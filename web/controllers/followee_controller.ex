defmodule Vutuv.FolloweeController do
  use Vutuv.Web, :controller

  def index(conn, _params) do
  	user = 
			conn.assigns[:user]
			|> Repo.preload([:followees, followee_connections: [:followee]])
    render(conn, "index.html", user: user)
  end
end
