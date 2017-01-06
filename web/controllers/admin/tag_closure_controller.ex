defmodule Vutuv.Admin.TagClosureController do
  use Vutuv.Web, :controller
  plug :logged_in?
  plug Vutuv.Plug.AuthAdmin

  alias Vutuv.TagClosure

  def index(conn, _params) do
    tag_closures = Repo.all(TagClosure)
    render(conn, "index.html", tag_closures: tag_closures)
  end

  def new(conn, _params) do
    changeset = TagClosure.changeset(%TagClosure{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tag_closure" => tag_closure_params}) do
    changeset = TagClosure.changeset(%TagClosure{}, tag_closure_params)

    case Repo.insert(changeset) do
      {:ok, _tag_closure} ->
        conn
        |> put_flash(:info, gettext("Tag closure created successfully."))
        |> redirect(to: admin_tag_closure_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tag_closure = Repo.get!(TagClosure, id)
    render(conn, "show.html", tag_closure: tag_closure)
  end

  def edit(conn, %{"id" => id}) do
    tag_closure = Repo.get!(TagClosure, id)
    changeset = TagClosure.changeset(tag_closure)
    render(conn, "edit.html", tag_closure: tag_closure, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tag_closure" => tag_closure_params}) do
    tag_closure = Repo.get!(TagClosure, id)
    changeset = TagClosure.changeset(tag_closure, tag_closure_params)

    case Repo.update(changeset) do
      {:ok, tag_closure} ->
        conn
        |> put_flash(:info, gettext("Tag closure updated successfully."))
        |> redirect(to: admin_tag_closure_path(conn, :show, tag_closure))
      {:error, changeset} ->
        render(conn, "edit.html", tag_closure: tag_closure, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tag_closure = Repo.get!(TagClosure, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(tag_closure)

    conn
    |> put_flash(:info, gettext("Tag closure deleted successfully."))
    |> redirect(to: admin_tag_closure_path(conn, :index))
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
end
