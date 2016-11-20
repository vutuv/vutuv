defmodule Vutuv.ConnectionController do
  use Vutuv.Web, :controller

  alias Vutuv.Connection

  plug :scrub_params, "connection" when action in [:create, :update]

  def index(conn, _params) do
    connections =
      Repo.all(Connection)
      |> Repo.preload([:follower, :followee])
    render(conn, "index.html", connections: connections)
  end

  def new(conn, _params) do
    changeset = Connection.changeset(%Connection{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"connection" => connection_params}) do
    changeset = Connection.changeset(%Connection{}, connection_params)

    case Repo.insert(changeset) do
      {:ok, _connection} ->
        conn
        |> put_flash(:info, gettext("Connection created successfully."))
        |> redirect(to: referrer_url(conn))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, gettext("Something went wrong"))
        |> redirect(to: referrer_url(conn))
    end
  end

  def show(conn, %{"id" => id}) do
    connection =
      Repo.get!(Connection, id)
      |> Repo.preload([:groups, :follower, :followee])

    render(conn, "show.html", connection: connection)
  end

  def delete(conn, %{"id" => id}) do
    connection = Repo.get!(Connection, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(connection)
    conn
    |> put_flash(:info, gettext("Connection deleted successfully."))
    |> redirect(to: referrer_url(conn))
  end

  def referrer_url(conn) do
    referrer = 
      conn
      |> Plug.Conn.get_req_header("referer")
      |> hd
      |> URI.parse
      |> Map.get(:path)
    if(referrer) do
      referrer
    else
      user_path(conn, :show, conn.assigns[:user])
    end
  end
end
