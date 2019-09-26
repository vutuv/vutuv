defmodule VutuvWeb.FolloweeControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.UserProfiles

  test "lists all of a user's followees (following)", %{conn: conn} do
    user = insert(:user)
    followee_ids = Enum.map(insert_list(12, :user), & &1.id)
    UserProfiles.add_followees(user, followee_ids)
    conn = get(conn, Routes.user_followee_path(conn, :index, user))
    assert html_response(conn, 200) =~ "Following"
  end
end
