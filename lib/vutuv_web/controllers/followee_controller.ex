defmodule VutuvWeb.FolloweeController do
  use VutuvWeb, :controller

  alias Vutuv.{UserProfiles, UserConnections}

  def index(conn, %{"user_slug" => slug} = params) do
    user = UserProfiles.get_user!(%{"slug" => slug})
    page = UserConnections.paginate_user_connections(user, params, :followees)
    render(conn, "index.html", user: user, followees: page.entries, page: page)
  end
end
