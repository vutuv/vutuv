defmodule Vutuv.FolloweeController do
  use Vutuv.Web, :controller
  alias Vutuv.Connection
  alias Vutuv.Pages

  def index(conn, _params) do
  	total = Vutuv.UserHelpers.followee_count(conn.assigns[:user])
  	query =
  		Connection.latest(100)
  		|> Pages.paginate(conn.params, total)
  	user = 
			conn.assigns[:user]
			|> Repo.preload([:followees, followee_connections: {query, [:followee]}])
    render(conn, "index.html", user: user, total_followees: total)
  end
end
