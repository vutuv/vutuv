defmodule Vutuv.Admin.TagClosureController do
  use Vutuv.Web, :controller
  plug :logged_in?
  plug Vutuv.Plug.AuthAdmin
  plug :resolve_tag

  alias Vutuv.TagClosure

  def index(conn, _params) do
    tag_closures = Repo.all(TagClosure)
    render(conn, "index.html", tag_closures: tag_closures)
  end

  def new(conn, _params) do
    changeset = TagClosure.changeset(%TagClosure{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tag_closure" => %{"type" => type, "value" => value}}) do
    id = Repo.one(from t in Vutuv.Tag, where: t.slug == ^value, select: t.id)
    if type == "parent" do
      TagClosure.add_closure(id, conn.assigns[:tag].id)
    else
      TagClosure.add_closure(conn.assigns[:tag].id, id)
    end
    |> case do
      {:ok, _tag_closure} ->
        conn
        |> put_flash(:info, gettext("Tag closure created successfully."))
        |> redirect(to: admin_tag_closure_path(conn, :index, conn.assigns[:tag]))
      {:error, _, changeset, errors} ->
        render(conn, "new.html", changeset: changeset, value: value)
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tag_closure = Repo.get!(TagClosure, id)
    render(conn, "show.html", tag_closure: tag_closure)
  end

  def delete(conn, %{"id" => id}) do
    tag_closure = Repo.get!(TagClosure, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    TagClosure.delete_closure(tag_closure.parent_id, tag_closure.child_id)

    conn
    |> put_flash(:info, gettext("Tag closure deleted successfully."))
    |> redirect(to: admin_tag_closure_path(conn, :index, conn.assigns[:tag]))
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

  defp resolve_tag(%{params: %{"tag_slug" => slug}} = conn, _opts) do
    Repo.one(from t in Vutuv.Tag, where: t.slug == ^slug)
    |> case do
      nil -> 
        conn
        |> put_status(:not_found)
        |> render(Vutuv.ErrorView, "404.html")
        |> halt
      tag ->
        assign(conn, :tag, tag |> Repo.preload([
          parent_closures: from(c in TagClosure, where: c.depth > 0, preload: [:parent]),
          child_closures: from(c in TagClosure, where: c.depth > 0, preload: [:child])]))
    end
  end
end
