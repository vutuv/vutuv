defmodule VutuvWeb.LeaderControllerTest do
  use VutuvWeb.ConnCase

  import Vutuv.Factory

  alias Vutuv.UserProfiles

  test "lists all of a user's leaders (following)", %{conn: conn} do
    user = insert(:user)
    leader_ids = Enum.map(insert_list(12, :user), & &1.id)
    UserProfiles.add_leaders(user, leader_ids)
    conn = get(conn, Routes.user_leader_path(conn, :index, user))
    assert html_response(conn, 200) =~ "Following"
  end
end
