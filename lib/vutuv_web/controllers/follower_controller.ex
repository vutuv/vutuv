defmodule VutuvWeb.FollowerController do
  use VutuvWeb, :controller

  alias Vutuv.UserProfiles

  def index(conn, %{"user_slug" => slug} = params) do
    user = UserProfiles.get_user!(%{"slug" => slug})
    page = UserProfiles.paginate_user_connections(user, params, :followers)
    render(conn, "index.html", user: user, followers: page.entries, page: page)
  end
end
