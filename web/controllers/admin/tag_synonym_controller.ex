defmodule Vutuv.Admin.TagSynonymController do
  use Vutuv.Web, :controller
  plug :logged_in?
  plug Vutuv.Plug.AuthAdmin
  plug :resolve_tag

  alias Vutuv.TagSynonym

  def index(conn, _params) do
    assoc =
      conn.assigns[:tag]
      |> assoc(:tag_synonyms)
    tag_synonyms = 
      from(f in assoc, preload: [:locale, :tag])
      |> Repo.all
    render(conn, "index.html", tag_synonyms: tag_synonyms)
  end

  def new(conn, _params) do
    changeset = TagSynonym.changeset(%TagSynonym{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tag_synonym" => tag_synonym_params}) do
    changeset = 
      conn.assigns[:tag]
      |> Ecto.build_assoc(:tag_synonyms)
      |> TagSynonym.changeset(tag_synonym_params)

    case Repo.insert(changeset) do
      {:ok, _tag_synonym} ->
        conn
        |> put_flash(:info, gettext("Tag synonym created successfully."))
        |> redirect(to: admin_tag_synonym_path(conn, :index, conn.assigns[:tag]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tag_synonym =
      conn.assigns[:tag]
      |> assoc(:tag_synonyms)
      |> Repo.get!(id)
      |> Repo.preload([:tag, :locale])
    render(conn, "show.html", tag_synonym: tag_synonym)
  end

  def edit(conn, %{"id" => id}) do
    tag_synonym =
      conn.assigns[:tag]
      |> assoc(:tag_synonyms)
      |> Repo.get!(id)
    changeset = TagSynonym.changeset(tag_synonym)
    render(conn, "edit.html", tag_synonym: tag_synonym, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tag_synonym" => tag_synonym_params}) do
    tag_synonym =
      conn.assigns[:tag]
      |> assoc(:tag_synonyms)
      |> Repo.get!(id)
    changeset = TagSynonym.changeset(tag_synonym, tag_synonym_params)

    case Repo.update(changeset) do
      {:ok, tag_synonym} ->
        conn
        |> put_flash(:info, gettext("Tag synonym updated successfully."))
        |> redirect(to: admin_tag_synonym_path(conn, :show, conn.assigns[:tag], tag_synonym))
      {:error, changeset} ->
        render(conn, "edit.html", tag_synonym: tag_synonym, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tag_synonym =
      conn.assigns[:tag]
      |> assoc(:tag_synonyms)
      |> Repo.get!(id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(tag_synonym)

    conn
    |> put_flash(:info, gettext("Tag synonym deleted successfully."))
    |> redirect(to: admin_tag_synonym_path(conn, :index, conn.assigns[:tag]))
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
        assign(conn, :tag, tag)
    end
  end
end
