defmodule Vutuv.Admin.ExonymController do
  use Vutuv.Web, :controller
  plug :logged_in?
  plug Vutuv.Plug.AuthAdmin

  alias Vutuv.Exonym

  def index(conn, _params) do
    exonyms = Repo.all(Exonym)
    render(conn, "index.html", exonyms: exonyms)
  end

  def new(conn, _params) do
    changeset = Exonym.changeset(%Exonym{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"exonym" => exonym_params}) do
    changeset = Exonym.changeset(%Exonym{}, exonym_params)

    case Repo.insert(changeset) do
      {:ok, _exonym} ->
        conn
        |> put_flash(:info, gettext("Exonym created successfully."))
        |> redirect(to: admin_exonym_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    exonym = Repo.get!(Exonym, id)
    render(conn, "show.html", exonym: exonym)
  end

  def edit(conn, %{"id" => id}) do
    exonym = Repo.get!(Exonym, id)
    changeset = Exonym.changeset(exonym)
    render(conn, "edit.html", exonym: exonym, changeset: changeset)
  end

  def update(conn, %{"id" => id, "exonym" => exonym_params}) do
    exonym = Repo.get!(Exonym, id)
    changeset = Exonym.changeset(exonym, exonym_params)

    case Repo.update(changeset) do
      {:ok, exonym} ->
        conn
        |> put_flash(:info, gettext("Exonym updated successfully."))
        |> redirect(to: admin_exonym_path(conn, :show, exonym))
      {:error, changeset} ->
        render(conn, "edit.html", exonym: exonym, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    exonym = Repo.get!(Exonym, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(exonym)

    conn
    |> put_flash(:info, gettext("Exonym deleted successfully."))
    |> redirect(to: admin_exonym_path(conn, :index))
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
