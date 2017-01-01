defmodule Vutuv.Admin.TagUrlController do
  use Vutuv.Web, :controller
  plug :logged_in?
  plug Vutuv.Plug.AuthAdmin

  alias Vutuv.TagUrl

  def index(conn, _params) do
    tag_urls = Repo.all(TagUrl)
    render(conn, "index.html", tag_urls: tag_urls)
  end

  def new(conn, _params) do
    changeset = TagUrl.changeset(%TagUrl{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tag_url" => tag_url_params}) do
    changeset = TagUrl.changeset(%TagUrl{}, tag_url_params)

    case Repo.insert(changeset) do
      {:ok, _tag_url} ->
        conn
        |> put_flash(:info, gettext("Tag url created successfully."))
        |> redirect(to: admin_tag_url_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tag_url = Repo.get!(TagUrl, id)
    render(conn, "show.html", tag_url: tag_url)
  end

  def edit(conn, %{"id" => id}) do
    tag_url = Repo.get!(TagUrl, id)
    changeset = TagUrl.changeset(tag_url)
    render(conn, "edit.html", tag_url: tag_url, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tag_url" => tag_url_params}) do
    tag_url = Repo.get!(TagUrl, id)
    changeset = TagUrl.changeset(tag_url, tag_url_params)

    case Repo.update(changeset) do
      {:ok, tag_url} ->
        conn
        |> put_flash(:info, gettext("Tag url updated successfully."))
        |> redirect(to: admin_tag_url_path(conn, :show, tag_url))
      {:error, changeset} ->
        render(conn, "edit.html", tag_url: tag_url, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tag_url = Repo.get!(TagUrl, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(tag_url)

    conn
    |> put_flash(:info, gettext("Tag url deleted successfully."))
    |> redirect(to: admin_tag_url_path(conn, :index))
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
