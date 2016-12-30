defmodule Vutuv.Admin.LocaleController do
  use Vutuv.Web, :controller
  plug :logged_in?
  plug Vutuv.Plug.AuthAdmin

  alias Vutuv.Locale

  def index(conn, _params) do
    locales = Repo.all(Locale)
    render(conn, "index.html", locales: locales)
  end

  def show(conn, %{"id" => id}) do
    locale = 
      Repo.get!(Locale, id)
      |> Repo.preload([exonyms: [:locale, :exonym_locale]])
    render(conn, "show.html", loc: locale)
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
