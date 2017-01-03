defmodule Vutuv.Admin.TagUrlController do
  use Vutuv.Web, :controller
  plug :logged_in?
  plug Vutuv.Plug.AuthAdmin
  plug :resolve_tag
  plug :resolve_tag_localization

  alias Vutuv.TagUrl

  def index(conn, _params) do
    assoc =
      conn.assigns[:tag_localization]
      |> assoc(:tag_urls)
    tag_urls = 
      from(f in assoc, preload: [:tag_localization])
      |> Repo.all
    render(conn, "index.html", tag_urls: tag_urls)
  end

  def new(conn, _params) do
    changeset = 
      conn.assigns[:tag_localization]
      |> Ecto.build_assoc(:tag_urls)
      |> TagUrl.changeset
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tag_url" => tag_url_params}) do
    changeset = 
      conn.assigns[:tag_localization]
      |> Ecto.build_assoc(:tag_urls)
      |> TagUrl.changeset(tag_url_params)

    case Repo.insert(changeset) do
      {:ok, _tag_url} ->
        conn
        |> put_flash(:info, gettext("Tag url created successfully."))
        |> redirect(to: admin_tag_localization_url_path(conn, :index, conn.assigns[:tag], conn.assigns[:tag_localization]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tag_url = 
      conn.assigns[:tag_localization]
      |> assoc(:tag_urls)
      |> Repo.get!(id)
      |> Repo.preload([:tag_localization])
    render(conn, "show.html", tag_url: tag_url)
  end

  def edit(conn, %{"id" => id}) do
    tag_url = 
      conn.assigns[:tag_localization]
      |> assoc(:tag_urls)
      |> Repo.get!(id)
    changeset = TagUrl.changeset(tag_url)
    render(conn, "edit.html", tag_url: tag_url, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tag_url" => tag_url_params}) do
    tag_url = 
      conn.assigns[:tag_localization]
      |> assoc(:tag_urls)
      |> Repo.get!(id)
    changeset = TagUrl.changeset(tag_url, tag_url_params)

    case Repo.update(changeset) do
      {:ok, tag_url} ->
        conn
        |> put_flash(:info, gettext("Tag url updated successfully."))
        |> redirect(to: admin_tag_localization_url_path(conn, :show, conn.assigns[:tag], conn.assigns[:tag_localization], tag_url))
      {:error, changeset} ->
        render(conn, "edit.html", tag_url: tag_url, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tag_url = 
      conn.assigns[:tag_localization]
      |> assoc(:tag_urls)
      |> Repo.get!(id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(tag_url)

    conn
    |> put_flash(:info, gettext("Tag url deleted successfully."))
    |> redirect(to: admin_tag_localization_url_path(conn, :index, conn.assigns[:tag], conn.assigns[:tag_localization]))
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

  defp resolve_tag(conn, _opts), do: conn

  defp resolve_tag_localization(%{params: %{"tag_localization_id" => id}} = conn, _opts) do
    conn.assigns[:tag]
    |> assoc(:tag_localizations)
    |> Repo.get!(id)
    |> case do
      nil -> 
        conn
        |> put_status(:not_found)
        |> render(Vutuv.ErrorView, "404.html")
        |> halt
      tag_localization ->
        assign(conn, :tag_localization, tag_localization)
    end
  end
end
