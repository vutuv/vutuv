defmodule Vutuv.FolloweeController do
  use Vutuv.Web, :controller
  alias Vutuv.Connection

  def index(conn, _params) do
  	user = 
			conn.assigns[:user]
			|> Repo.preload([:followees, followee_connections: {Connection.latest(100), [:followee]}])
    render(conn, "index.html", user: user)
  end
end
