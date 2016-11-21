defmodule Vutuv.UrlController do
  use Vutuv.Web, :controller
  alias Vutuv.Url

  plug Vutuv.Plug.AuthUser when action in [:new, :create, :edit, :update, :delete]
  plug :scrub_params, "url" when action in [:create, :update]

  def index(conn, _params) do
    urls = Repo.all(assoc(conn.assigns[:user], :urls))
    render(conn, "index.html", urls: urls)
  end

  def new(conn, _params) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:urls)
      |> Url.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"url" => url_params}) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:urls)
      |> Url.changeset(url_params)

    case Repo.insert(changeset) do
      {:ok, _url} ->
        conn
        |> put_flash(:info, gettext("Link created successfully."))
        |> redirect(to: user_url_path(conn, :index, conn.assigns[:user]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    url = Repo.get!(assoc(conn.assigns[:user], :urls), id)
    render(conn, "show.html", url: url)
  end

  def edit(conn, %{"id" => id}) do
    url = Repo.get!(assoc(conn.assigns[:user], :urls), id)
    changeset = Url.changeset(url)
    render(conn, "edit.html", url: url, changeset: changeset)
  end

  def update(conn, %{"id" => id, "url" => url_params}) do
    url = Repo.get!(assoc(conn.assigns[:user], :urls), id)
    changeset = Url.changeset(url, url_params)
    case Repo.update(changeset) do
      {:ok, url} ->
        conn
        |> put_flash(:info, gettext("Link updated successfully."))
        |> redirect(to: user_url_path(conn, :show, conn.assigns[:user], url))
      {:error, changeset} ->
        render(conn, "edit.html", url: url, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    url = Repo.get!(assoc(conn.assigns[:user], :urls), id)
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    
    Repo.delete!(url)
    conn
    |> put_flash(:info, gettext("Link deleted successfully."))
    |> redirect(to: user_url_path(conn, :index, conn.assigns[:user]))
  end
end
