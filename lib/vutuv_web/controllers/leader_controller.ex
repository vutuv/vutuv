defmodule VutuvWeb.LeaderController do
  use VutuvWeb, :controller

  alias Vutuv.Accounts

  def index(conn, %{"user_slug" => slug} = params) do
    user = Accounts.get_user!(%{"slug" => slug})
    page = Accounts.paginate_user_connections(user, params, :leaders)
    render(conn, "index.html", user: user, leaders: page.entries, page: page)
  end
end
