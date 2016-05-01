defmodule Vutuv.PageController do
  use Vutuv.Web, :controller
  alias Vutuv.User

  def index(conn, _params) do
    user_count = Repo.one(from u in User, select: count("*"))
    render conn, "index.html", user_count: user_count
  end
end
