defmodule Vutuv.Admin.TagSynonymController do
  use Vutuv.Web, :controller
  plug :logged_in?
  plug Vutuv.Plug.AuthAdmin

  alias Vutuv.TagSynonym

  def index(conn, _params) do
    tag_synonyms = Repo.all(TagSynonym)
    render(conn, "index.html", tag_synonyms: tag_synonyms)
  end

  def new(conn, _params) do
    changeset = TagSynonym.changeset(%TagSynonym{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tag_synonym" => tag_synonym_params}) do
    changeset = TagSynonym.changeset(%TagSynonym{}, tag_synonym_params)

    case Repo.insert(changeset) do
      {:ok, _tag_synonym} ->
        conn
        |> put_flash(:info, gettext("Tag synonym created successfully."))
        |> redirect(to: admin_tag_synonym_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tag_synonym = Repo.get!(TagSynonym, id)
    render(conn, "show.html", tag_synonym: tag_synonym)
  end

  def edit(conn, %{"id" => id}) do
    tag_synonym = Repo.get!(TagSynonym, id)
    changeset = TagSynonym.changeset(tag_synonym)
    render(conn, "edit.html", tag_synonym: tag_synonym, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tag_synonym" => tag_synonym_params}) do
    tag_synonym = Repo.get!(TagSynonym, id)
    changeset = TagSynonym.changeset(tag_synonym, tag_synonym_params)

    case Repo.update(changeset) do
      {:ok, tag_synonym} ->
        conn
        |> put_flash(:info, gettext("Tag synonym updated successfully."))
        |> redirect(to: admin_tag_synonym_path(conn, :show, tag_synonym))
      {:error, changeset} ->
        render(conn, "edit.html", tag_synonym: tag_synonym, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tag_synonym = Repo.get!(TagSynonym, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(tag_synonym)

    conn
    |> put_flash(:info, gettext("Tag synonym deleted successfully."))
    |> redirect(to: admin_tag_synonym_path(conn, :index))
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
