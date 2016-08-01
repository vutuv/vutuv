defmodule Vutuv.Admin.SlugController do
  use Vutuv.Web, :controller
  plug :logged_in?
  import Vutuv.UserHelpers

  alias Vutuv.Slug

  def index(conn, _params) do
    slug = Repo.all(from s in Slug)
    changeset = Slug.changeset(%Slug{})
    render(conn, "index.html")
  end

  def update(conn, %{"slug"=> params}) do
    conn
    |> put_flash(:info, conn.assigns["administrate_slugs"]["disabled_slug"])
    |> redirect(to: admin_slug_path(conn, :index))
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
end
