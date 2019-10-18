defmodule VutuvWeb.FolloweeController do
  use VutuvWeb, :controller

  alias Vutuv.{UserProfiles, UserConnections}

  def index(conn, %{"user_slug" => slug} = params) do
    user = UserProfiles.get_user!(%{"slug" => slug})
    page = UserConnections.paginate_user_connections(user, params, :followees)
    render(conn, "index.html", user: user, followees: page.entries, page: page)
  end

  def create(conn, %{"user_slug" => user_slug, "followee" => followee_params}) do
    if current_user_check(conn.assigns.current_user, followee_params) do
      create_followee(conn, user_slug, followee_params)
    else
      conn
      |> put_flash(:error, gettext("Unauthorized to follow user."))
      |> redirect(to: Routes.user_path(conn, :show, user_slug))
    end
  end

  defp create_followee(conn, user_slug, followee_params) do
    case UserConnections.create_user_connection(followee_params) do
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

  def delete(conn, %{"user_slug" => user_slug, "id" => id}) do
    user_connection = UserConnections.get_user_connection!(id)

    if current_user_check(conn.assigns.current_user, user_connection) do
      delete_followee(conn, user_slug, user_connection)
    else
      conn
      |> put_flash(:error, gettext("Unauthorized to unfollow user."))
      |> redirect(to: Routes.user_path(conn, :show, user_slug))
    end
  end

  defp delete_followee(conn, user_slug, user_connection) do
    {:ok, _user_connection} = UserConnections.delete_user_connection(user_connection)

    conn
    |> put_flash(:info, gettext("Not following user."))
    |> redirect(to: Routes.user_path(conn, :show, user_slug))
  end

  defp current_user_check(%{id: user_id}, %{"follower_id" => follower_id}) do
    user_id == follower_id
  end

  defp current_user_check(%{id: user_id}, %{follower_id: follower_id}) do
    user_id == follower_id
  end

  defp current_user_check(_, _), do: false
end
