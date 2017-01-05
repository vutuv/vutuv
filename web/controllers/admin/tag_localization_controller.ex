defmodule Vutuv.Admin.TagLocalizationController do
  use Vutuv.Web, :controller
  plug :logged_in?
  plug Vutuv.Plug.AuthAdmin
  plug :resolve_tag

  alias Vutuv.TagLocalization

  def index(conn, _params) do
    assoc =
      conn.assigns[:tag]
      |> assoc(:tag_localizations)
    tag_localizations = 
      from(f in assoc, preload: [:locale, :tag])
      |> Repo.all
    render(conn, "index.html", tag_localizations: tag_localizations)
  end

  def new(conn, _params) do
    changeset = 
    conn.assigns[:tag]
    |> Ecto.build_assoc(:tag_localizations)
    |> TagLocalization.changeset
    
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tag_localization" => tag_localization_params}) do
    changeset = 
    conn.assigns[:tag]
    |> Ecto.build_assoc(:tag_localizations)
    |> TagLocalization.changeset(tag_localization_params)

    case Repo.insert(changeset) do
      {:ok, _tag_localization} ->
        conn
        |> put_flash(:info, gettext("Tag localization created successfully."))
        |> redirect(to: admin_tag_localization_path(conn, :index, conn.assigns[:tag]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tag_localization = 
      conn.assigns[:tag]
      |> assoc(:tag_localizations)
      |> Repo.get!(id)
      |> Repo.preload([:locale, :tag, tag_urls: [:tag_localization]])
    render(conn, "show.html", tag_localization: tag_localization)
  end

  def edit(conn, %{"id" => id}) do
    tag_localization = 
      conn.assigns[:tag]
      |> assoc(:tag_localizations)
      |> Repo.get!(id)
    changeset = TagLocalization.changeset(tag_localization)
    render(conn, "edit.html", tag_localization: tag_localization, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tag_localization" => tag_localization_params}) do
    tag_localization = 
      conn.assigns[:tag]
      |> assoc(:tag_localizations)
      |> Repo.get!(id)
    changeset = TagLocalization.changeset(tag_localization, tag_localization_params)

    case Repo.update(changeset) do
      {:ok, tag_localization} ->
        conn
        |> put_flash(:info, gettext("Tag localization updated successfully."))
        |> redirect(to: admin_tag_localization_path(conn, :show, conn.assigns[:tag], tag_localization))
      {:error, changeset} ->
        render(conn, "edit.html", tag_localization: tag_localization, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tag_localization = 
      conn.assigns[:tag]
      |> assoc(:tag_localizations)
      |> Repo.get!(id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(tag_localization)

    conn
    |> put_flash(:info, gettext("Tag localization deleted successfully."))
    |> redirect(to: admin_tag_localization_path(conn, :index, conn.assigns[:tag]))
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
