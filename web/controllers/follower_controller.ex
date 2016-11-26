defmodule Vutuv.FollowerController do
  use Vutuv.Web, :controller
  alias Vutuv.Connection
  alias Vutuv.Pages

  def index(conn, _params) do
  	total = Vutuv.UserHelpers.follower_count(conn.assigns[:user])
  	query =
  		Connection.latest(100)
  		|> Pages.paginate(conn.params, total)
  	user = 
			conn.assigns[:user]
			|> Repo.preload([:followers, follower_connections: {query, [:follower]}])
    render(conn, "index.html", user: user, total_followees: total)
  end
end
