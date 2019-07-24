defmodule VutuvWeb.FollowerControllerTest do
  use VutuvWeb.ConnCase

  import Vutuv.Factory

  alias Vutuv.Accounts

  test "lists all of a user's followers", %{conn: conn} do
    user = insert(:user)
    followers = insert_list(12, :user)
    for follower <- followers, do: Accounts.add_leaders(follower, [user.id])
    conn = get(conn, Routes.user_follower_path(conn, :index, user))
    assert html_response(conn, 200) =~ "Followers"
  end
end
