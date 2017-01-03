defmodule Vutuv.Admin.TagController do
  use Vutuv.Web, :controller
  plug :logged_in?
  plug Vutuv.Plug.AuthAdmin
  plug :resolve_tag

  alias Vutuv.Tag

  def index(conn, _params) do
    tags = Repo.all(Tag)
    render(conn, "index.html", tags: tags)
  end

  def new(conn, _params) do
    changeset = Tag.changeset(%Tag{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tag" => tag_params}) do
    changeset = Tag.changeset(%Tag{}, tag_params, conn.assigns[:locale])

    case Repo.insert(changeset) do
      {:ok, _tag} ->
        conn
        |> put_flash(:info, gettext("Tag created successfully."))
        |> redirect(to: admin_tag_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, _params) do
    tag =
      conn.assigns[:tag]
      |> Repo.preload([
        tag_synonyms: from(f in Vutuv.TagSynonym,  limit: 5, preload: [:tag, :locale]),
        tag_localizations: from(f in Vutuv.TagLocalization, limit: 5, preload: [:tag, :locale, :tag_urls])])
    render(conn, "show.html", tag: tag)
  end

  def edit(conn, _params) do
    tag =  conn.assigns[:tag]
    changeset = Tag.edit_changeset(tag)
    render(conn, "edit.html", tag: tag, changeset: changeset)
  end

  def update(conn, %{"tag" => tag_params}) do
    tag = 
      conn.assigns[:tag]
    changeset = Tag.edit_changeset(tag, tag_params)

    case Repo.update(changeset) do
      {:ok, tag} ->
        conn
        |> put_flash(:info, gettext("Tag updated successfully."))
        |> redirect(to: admin_tag_path(conn, :show, tag))
      {:error, changeset} ->
        render(conn, "edit.html", tag: tag, changeset: changeset)
    end
  end

  def delete(conn, _params) do

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(conn.assigns[:tag])

    conn
    |> put_flash(:info, gettext("Tag deleted successfully."))
    |> redirect(to: admin_tag_path(conn, :index))
  end

  defp resolve_tag(%{params: %{"slug" => slug}} = conn, _opts) do
    Repo.one(from t in Vutuv.Tag, where: t.slug == ^slug)
    |> case do
      nil -> 
        conn
        |> put_status(:not_found)
        |> render(Vutuv.ErrorView, "404.html")
        |> halt
      tag ->
        assign(conn, :tag, tag)
    end
  end

  defp resolve_tag(conn, _opts), do: conn

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
