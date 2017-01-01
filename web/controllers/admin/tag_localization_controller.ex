defmodule Vutuv.Admin.TagLocalizationController do
  use Vutuv.Web, :controller
  plug :logged_in?
  plug Vutuv.Plug.AuthAdmin

  alias Vutuv.TagLocalization

  def index(conn, _params) do
    tag_localizations = Repo.all(TagLocalization)
      |> Repo.preload([:locale])
    render(conn, "index.html", tag_localizations: tag_localizations)
  end

  def new(conn, _params) do
    changeset = TagLocalization.changeset(%TagLocalization{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tag_localization" => tag_localization_params}) do
    changeset = TagLocalization.changeset(%TagLocalization{}, tag_localization_params)

    case Repo.insert(changeset) do
      {:ok, _tag_localization} ->
        conn
        |> put_flash(:info, gettext("Tag localization created successfully."))
        |> redirect(to: admin_tag_localization_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tag_localization = Repo.get!(TagLocalization, id)
    render(conn, "show.html", tag_localization: tag_localization)
  end

  def edit(conn, %{"id" => id}) do
    tag_localization = Repo.get!(TagLocalization, id)
    changeset = TagLocalization.changeset(tag_localization)
    render(conn, "edit.html", tag_localization: tag_localization, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tag_localization" => tag_localization_params}) do
    tag_localization = Repo.get!(TagLocalization, id)
    changeset = TagLocalization.changeset(tag_localization, tag_localization_params)

    case Repo.update(changeset) do
      {:ok, tag_localization} ->
        conn
        |> put_flash(:info, gettext("Tag localization updated successfully."))
        |> redirect(to: admin_tag_localization_path(conn, :show, tag_localization))
      {:error, changeset} ->
        render(conn, "edit.html", tag_localization: tag_localization, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tag_localization = Repo.get!(TagLocalization, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(tag_localization)

    conn
    |> put_flash(:info, gettext("Tag localization deleted successfully."))
    |> redirect(to: admin_tag_localization_path(conn, :index))
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
