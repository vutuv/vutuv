defmodule Vutuv.Admin.UserController do
  use Vutuv.Web, :controller
  plug :logged_in?
  plug Vutuv.Plug.AuthAdmin

  alias Vutuv.User

  def update(conn, %{"user_id"=> user_id}) do
    user = Repo.get(User, user_id)
    changeset = Ecto.Changeset.cast(user, %{verified: true}, [:verified])
    case Repo.update(changeset) do
      {:ok, user} ->
        Vutuv.Emailer.verification_notice(user)
        conn
        |> put_flash(:info, gettext("User verified successfully."))
        |> redirect(to: user_path(conn, :show, user))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, gettext("An error occurred"))
        |> redirect(to: user_path(conn, :show, user))
    end
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
