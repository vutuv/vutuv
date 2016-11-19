defmodule Vutuv.Admin.AdminController do
  use Vutuv.Web, :controller
  plug :logged_in?
  plug :authorize

  alias Vutuv.User

  def index(conn, _params) do
    users = Repo.all(from u in User, where: u.verified != true)
    render conn, "index.html", users: users
  end

  defp logged_in?(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, gettext("You must be logged in to access that page"))
      |> redirect(to: page_path(conn, :index))
      |> halt()
    end
  end

  defp authorize(conn, _params) do
    if conn.assigns[:current_user].administrator==false do
      conn
      |> put_status(403)
      |> render(Vutuv.ErrorView, "403.html")
      |> halt
    else
      conn
    end
  end
end
