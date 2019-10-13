defmodule VutuvWeb.FollowerControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.UserConnections

  test "lists all of a user's followers", %{conn: conn} do
    user = insert(:user)
    followers = insert_list(12, :user)
    for follower <- followers, do: UserConnections.add_followees(follower, [user.id])
    conn = get(conn, Routes.user_follower_path(conn, :index, user))
    assert html_response(conn, 200) =~ "Followers"
  end
end
