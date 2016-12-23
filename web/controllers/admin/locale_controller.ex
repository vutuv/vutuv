defmodule Vutuv.Admin.LocaleController do
  use Vutuv.Web, :controller
  plug :logged_in?
  plug Vutuv.Plug.AuthAdmin

  alias Vutuv.Locale

  def index(conn, _params) do
    locales = Repo.all(Locale)
    render(conn, "index.html", locales: locales)
  end

  def new(conn, _params) do
    changeset = Locale.changeset(%Locale{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"locale" => locale_params}) do
    changeset = Locale.changeset(%Locale{}, locale_params)

    case Repo.insert(changeset) do
      {:ok, _locale} ->
        conn
        |> put_flash(:info, gettext("Locale created successfully."))
        |> redirect(to: admin_locale_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    locale = Repo.get!(Locale, id)
    render(conn, "show.html", locale: locale)
  end

  def edit(conn, %{"id" => id}) do
    locale = Repo.get!(Locale, id)
    changeset = Locale.changeset(locale)
    render(conn, "edit.html", locale: locale, changeset: changeset)
  end

  def update(conn, %{"id" => id, "locale" => locale_params}) do
    locale = Repo.get!(Locale, id)
    changeset = Locale.changeset(locale, locale_params)

    case Repo.update(changeset) do
      {:ok, locale} ->
        conn
        |> put_flash(:info, gettext("Locale updated successfully."))
        |> redirect(to: admin_locale_path(conn, :show, locale))
      {:error, changeset} ->
        render(conn, "edit.html", locale: locale, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    locale = Repo.get!(Locale, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(locale)

    conn
    |> put_flash(:info, gettext("Locale deleted successfully."))
    |> redirect(to: admin_locale_path(conn, :index))
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
