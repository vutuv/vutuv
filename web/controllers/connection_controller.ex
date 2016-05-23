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
        |> put_flash(:info, "Connection created successfully.")
        |> redirect(to: connection_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    connection =
      Repo.get!(Connection, id)
      |> Repo.preload([:follower, :followee])
    
    render(conn, "show.html", connection: connection)
  end

  def edit(conn, %{"id" => id}) do
    connection = Repo.get!(Connection, id)
    changeset = Connection.changeset(connection)
    render(conn, "edit.html", connection: connection, changeset: changeset)
  end

  def update(conn, %{"id" => id, "connection" => connection_params}) do
    connection = Repo.get!(Connection, id)
    changeset = Connection.changeset(connection, connection_params)

    case Repo.update(changeset) do
      {:ok, connection} ->
        conn
        |> put_flash(:info, "Connection updated successfully.")
        |> redirect(to: connection_path(conn, :show, connection))
      {:error, changeset} ->
        render(conn, "edit.html", connection: connection, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    connection = Repo.get!(Connection, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(connection)

    conn
    |> put_flash(:info, "Connection deleted successfully.")
    |> redirect(to: user_path(conn, :show, conn.assigns[:current_user]))
  end
end
