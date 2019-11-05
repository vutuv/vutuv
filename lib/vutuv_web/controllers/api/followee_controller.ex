defmodule VutuvWeb.Api.FolloweeController do
  use VutuvWeb, :controller

  import VutuvWeb.Api.Authorize

  alias Vutuv.{UserConnections, UserProfiles}

  action_fallback VutuvWeb.Api.FallbackController

  def index(conn, %{"user_slug" => slug}) do
    user = UserProfiles.get_user!(%{"slug" => slug})
    user_connections = UserConnections.list_user_connections(user, :followees)
    render(conn, "index.json", user: user, user_connections: user_connections)
  end

  def create(conn, %{"user_slug" => user_slug, "followee" => followee_params}) do
    if current_user_check(conn.assigns.current_user, followee_params) do
      create_followee(conn, user_slug, followee_params)
    else
      error(conn, :forbidden, 403)
    end
  end

  def create_followee(conn, user_slug, followee_params) do
    with {:ok, user_connection} <- UserConnections.create_user_connection(followee_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user_slug))
      |> render("show.json", user_connection: user_connection)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_connection = UserConnections.get_user_connection!(id)

    if current_user_check(conn.assigns.current_user, user_connection) do
      delete_followee(conn, user_connection)
    else
      error(conn, :forbidden, 403)
    end
  end

  def delete_followee(conn, user_connection) do
    with {:ok, _user_connection} <- UserConnections.delete_user_connection(user_connection) do
      send_resp(conn, :no_content, "")
    end
  end

  defp current_user_check(%{id: user_id}, %{"follower_id" => follower_id}) do
    to_string(user_id) == follower_id
  end

  defp current_user_check(%{id: user_id}, %{follower_id: follower_id}) do
    user_id == follower_id
  end

  defp current_user_check(_, _), do: false
end
