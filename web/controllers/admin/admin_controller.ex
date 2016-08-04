defmodule Vutuv.Admin.AdminController do
  use Vutuv.Web, :controller
  plug :logged_in?
  plug :authorize

  def index(conn, _params) do
    render conn, "index.html"
  end

  defp logged_in?(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
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
