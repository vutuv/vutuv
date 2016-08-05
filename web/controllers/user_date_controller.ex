defmodule Vutuv.UserDateController do
  use Vutuv.Web, :controller
  plug :auth_user

  alias Vutuv.UserDate

  plug :scrub_params, "user_date" when action in [:create, :update]

  def index(conn, _params) do
    user_dates = Repo.all(assoc(conn.assigns[:user], :user_dates))
    render(conn, "index.html", user_dates: user_dates)
  end

  def new(conn, _params) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:user_dates)
      |> UserDate.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user_date" => user_date_params}) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:user_dates)
      |> UserDate.changeset(user_date_params)

    case Repo.insert(changeset) do
      {:ok, _user_date} ->
        conn
        |> put_flash(:info, "Date created successfully.")
        |> redirect(to: user_user_date_path(conn, :index, conn.assigns[:user]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user_date = Repo.get!(assoc(conn.assigns[:user], :user_dates), id)
    render(conn, "show.html", user_date: user_date)
  end

  def edit(conn, %{"id" => id}) do
    user_date = Repo.get!(assoc(conn.assigns[:user], :user_dates), id)
    changeset = UserDate.changeset(user_date)
    render(conn, "edit.html", user_date: user_date, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user_date" => user_date_params}) do
    user_date = Repo.get!(assoc(conn.assigns[:user], :user_dates), id)
    changeset = UserDate.changeset(user_date, user_date_params)
    case Repo.update(changeset) do
      {:ok, user_date} ->
        conn
        |> put_flash(:info, "Date updated successfully.")
        |> redirect(to: user_user_date_path(conn, :show, conn.assigns[:user], user_date))
      {:error, changeset} ->
        render(conn, "edit.html", user_date: user_date, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_date = Repo.get!(assoc(conn.assigns[:user], :user_dates), id)
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    
    Repo.delete!(user_date)
    conn
    |> put_flash(:info, "Date deleted successfully.")
    |> redirect(to: user_user_date_path(conn, :index, conn.assigns[:user]))

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
