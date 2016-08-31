defmodule Vutuv.DateController do
  use Vutuv.Web, :controller
  plug :auth_user

  alias Vutuv.Date

  plug :scrub_params, "date" when action in [:create, :update]

  def index(conn, _params) do
    dates = Repo.all(assoc(conn.assigns[:user], :dates))
    render(conn, "index.html", dates: dates)
  end

  def new(conn, _params) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:dates)
      |> Date.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"date" => date_params}) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:dates)
      |> Date.changeset(date_params)

    case Repo.insert(changeset) do
      {:ok, _date} ->
        conn
        |> put_flash(:info, "Date created successfully.")
        |> redirect(to: user_date_path(conn, :index, conn.assigns[:user]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    date = Repo.get!(assoc(conn.assigns[:user], :dates), id)
    render(conn, "show.html", date: date)
  end

  def edit(conn, %{"id" => id}) do
    date = Repo.get!(assoc(conn.assigns[:user], :dates), id)
    changeset = Date.changeset(date)
    render(conn, "edit.html", date: date, changeset: changeset)
  end

  def update(conn, %{"id" => id, "date" => date_params}) do
    date = Repo.get!(assoc(conn.assigns[:user], :dates), id)
    changeset = Date.changeset(date, date_params)
    case Repo.update(changeset) do
      {:ok, date} ->
        conn
        |> put_flash(:info, "Date updated successfully.")
        |> redirect(to: user_date_path(conn, :show, conn.assigns[:user], date))
      {:error, changeset} ->
        render(conn, "edit.html", date: date, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    date = Repo.get!(assoc(conn.assigns[:user], :dates), id)
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    
    Repo.delete!(date)
    conn
    |> put_flash(:info, "Date deleted successfully.")
    |> redirect(to: user_date_path(conn, :index, conn.assigns[:user]))

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
