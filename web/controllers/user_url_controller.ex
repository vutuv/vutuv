defmodule Vutuv.UserUrlController do
  use Vutuv.Web, :controller
  plug :auth_user

  alias Vutuv.UserUrl

  plug :scrub_params, "user_url" when action in [:create, :update]

  def index(conn, _params) do
    urls = Repo.all(assoc(conn.assigns[:user], :user_urls))
    render(conn, "index.html", urls: urls)
  end

  def new(conn, _params) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:user_urls)
      |> UserUrl.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user_url" => url_params}) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:user_urls)
      |> UserUrl.changeset(url_params)

    case Repo.insert(changeset) do
      {:ok, _url} ->
        conn
        |> put_flash(:info, "Link created successfully.")
        |> redirect(to: user_user_url_path(conn, :index, conn.assigns[:user]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    url = Repo.get!(assoc(conn.assigns[:user], :user_urls), id)
    render(conn, "show.html", url: url)
  end

  def edit(conn, %{"id" => id}) do
    url = Repo.get!(assoc(conn.assigns[:user], :user_urls), id)
    changeset = UserUrl.changeset(url)
    render(conn, "edit.html", url: url, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user_url" => url_params}) do
    url = Repo.get!(assoc(conn.assigns[:user], :user_urls), id)
    changeset = UserUrl.changeset(url, url_params)
    case Repo.update(changeset) do
      {:ok, url} ->
        conn
        |> put_flash(:info, "Link updated successfully.")
        |> redirect(to: user_user_url_path(conn, :show, conn.assigns[:user], url))
      {:error, changeset} ->
        render(conn, "edit.html", url: url, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    url = Repo.get!(assoc(conn.assigns[:user], :user_urls), id)
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    
    Repo.delete!(url)
    conn
    |> put_flash(:info, "Link deleted successfully.")
    |> redirect(to: user_user_url_path(conn, :index, conn.assigns[:user]))
  end

  defp auth_user(conn, _opts) do
    if(conn.assigns[:user].id == conn.assigns[:current_user].id) do
      conn
    else
      redirect(conn, to: user_path(conn, :show, conn.assigns[:current_user]))
      |> halt
    end
  end
end
