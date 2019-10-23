defmodule VutuvWeb.FolloweeControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.UserConnections

  setup %{conn: conn} do
    conn = conn |> bypass_through(VutuvWeb.Router, [:browser]) |> get("/")
    user = add_user("igor@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "read followees" do
    test "lists all of a user's followees (following)", %{conn: conn, user: user} do
      followee_ids = Enum.map(insert_list(12, :user), & &1.id)

      Enum.each(
        followee_ids,
        &UserConnections.create_user_connection(%{"followee_id" => &1, "follower_id" => user.id})
      )

      conn = get(conn, Routes.user_followee_path(conn, :index, user))
      assert html_response(conn, 200) =~ "Following"
    end
  end

  describe "write followees" do
    setup [:add_session_to_conn]

    test "creates a followee if follower is current_user", %{conn: conn, user: user} do
      other = insert(:user)
      create_attrs = %{"followee_id" => other.id, "follower_id" => to_string(user.id)}
      conn = post(conn, Routes.user_followee_path(conn, :create, other), followee: create_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, other)
      assert get_flash(conn, :info) =~ "Following user"
    end

    test "cannot create a followee if follower is not current_user", %{conn: conn} do
      [user, other] = insert_list(2, :user)
      create_attrs = %{"followee_id" => other.id, "follower_id" => user.id}
      conn = post(conn, Routes.user_followee_path(conn, :create, other), followee: create_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, other)
      assert get_flash(conn, :error) =~ "Unauthorized to follow user"
    end
  end

  describe "delete followees" do
    setup [:add_session_to_conn]

    test "deletes a followee if follower is current_user", %{conn: conn, user: user} do
      other = insert(:user)

      {:ok, user_connection} =
        UserConnections.create_user_connection(%{
          "followee_id" => other.id,
          "follower_id" => user.id
        })

      conn = delete(conn, Routes.user_followee_path(conn, :delete, other, user_connection))
      assert redirected_to(conn) == Routes.user_path(conn, :show, other)
      assert get_flash(conn, :info) =~ "Not following user"
    end

    test "cannot delete a followee if follower is not current_user", %{conn: conn} do
      [user, other] = insert_list(2, :user)

      {:ok, user_connection} =
        UserConnections.create_user_connection(%{
          "followee_id" => other.id,
          "follower_id" => user.id
        })

      conn = delete(conn, Routes.user_followee_path(conn, :delete, other, user_connection))
      assert redirected_to(conn) == Routes.user_path(conn, :show, other)
      assert get_flash(conn, :error) =~ "Unauthorized to unfollow user"
    end
  end
end
