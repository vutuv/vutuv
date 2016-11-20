defmodule Vutuv.FollowerController do
  use Vutuv.Web, :controller
  alias Vutuv.Connection

  def index(conn, _params) do
  	user = 
			conn.assigns[:user]
			|> Repo.preload([:followers, follower_connections: {Connection.latest(1000), [:follower]}])
    render(conn, "index.html", user: user)
  end
end
