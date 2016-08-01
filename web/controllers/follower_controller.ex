defmodule Vutuv.FollowerController do
  use Vutuv.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html", user: conn.assigns[:user])
  end
end
