defmodule Vutuv.Admin.UserController do
  use Vutuv.Web, :controller
  plug :logged_in?
  import Vutuv.UserHelpers

  alias Vutuv.User

  def update(conn, %{"user_id"=> user_id}=params) do
    user = Repo.get(User, user_id)
    changeset = Ecto.Changeset.cast(user, %{verified: true}, [:verified])
    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User verified successfully.")
        |> redirect(to: admin_admin_path(conn, :index))
      {:error, changeset} ->
        render(conn, "index.html")
    end
  end

  defp logged_in?(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: page_path(conn, :index))
      |> halt()
    end
  end
end
