defmodule VutuvWeb.FolloweeController do
  use VutuvWeb, :controller

  alias Vutuv.{UserProfiles, UserConnections}

  def index(conn, %{"user_slug" => slug} = params) do
    user = UserProfiles.get_user!(%{"slug" => slug})
    page = UserConnections.paginate_user_connections(user, params, :followees)
    render(conn, "index.html", user: user, followees: page.entries, page: page)
  end

  # need check that follower is current_user
  def create(conn, %{"user_slug" => user_slug, "followee" => params}) do
    case UserConnections.create_user_connection(params) do
      {:ok, _user_connection} ->
        conn
        |> put_flash(:info, gettext("Following user."))
        |> redirect(to: Routes.user_path(conn, :show, user_slug))

      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(:error, gettext("Error when trying to follow user."))
        |> redirect(to: Routes.user_path(conn, :show, user_slug))
    end
  end

  # need check that follower is current_user
  def delete(conn, %{"user_slug" => user_slug, "id" => id}) do
    user_connection = UserConnections.get_user_connection!(id)
    {:ok, _user_connection} = UserConnections.delete_user_connection(user_connection)

    conn
    |> put_flash(:info, gettext("Not following user."))
    |> redirect(to: Routes.user_path(conn, :show, user_slug))
  end
end
