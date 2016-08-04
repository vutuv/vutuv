defmodule Vutuv.Admin.SlugController do
  use Vutuv.Web, :controller
  plug :logged_in?
  import Vutuv.UserHelpers

  alias Vutuv.Slug

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def update(conn, %{"slug_disable"=> %{"value"=> value}}) do
    case Repo.one(from s in Slug, where: s.value==^value) do
      nil ->
        conn
        |> put_flash(:error, "Slug doesn't exist.")
        |> render("index.html")
      slug->
        changeset = Ecto.Changeset.cast(slug, %{disabled: true}, [:disabled])
        case Repo.update(changeset) do
          {:ok, slug} ->
            conn
            |> put_flash(:info, "Slug disabled successfully.")
            |> redirect(to: admin_admin_path(conn, :index))
          {:error, changeset} ->
            render(conn, "index.html")
        end
    end
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
