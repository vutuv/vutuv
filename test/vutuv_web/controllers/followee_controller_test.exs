defmodule VutuvWeb.FolloweeControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.UserConnections

  test "lists all of a user's followees (following)", %{conn: conn} do
    user = insert(:user)
    followee_ids = Enum.map(insert_list(12, :user), & &1.id)

    Enum.each(
      followee_ids,
      &UserConnections.create_user_connection(%{"followee_id" => &1, "follower_id" => user.id})
    )

    conn = get(conn, Routes.user_followee_path(conn, :index, user))
    assert html_response(conn, 200) =~ "Following"
  end

  test "creates a followee - follows a user" do
  end

  test "deletes a followee" do
  end
end
