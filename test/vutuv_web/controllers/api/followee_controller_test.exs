defmodule VutuvWeb.Api.FolloweeControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.UserConnections

  setup %{conn: conn} do
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

      conn = get(conn, Routes.api_user_followee_path(conn, :index, user))
      assert followees = json_response(conn, 200)["data"]
      assert length(followees) == 12
    end
  end

  describe "write followees" do
    setup [:add_token_to_conn]

    test "creates a followee if follower is current_user", %{conn: conn, user: user} do
      other = insert(:user)
      create_attrs = %{"followee_id" => other.id, "follower_id" => to_string(user.id)}

      conn =
        post(conn, Routes.api_user_followee_path(conn, :create, other), followee: create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]
    end

    test "cannot create a followee if follower is not current_user", %{conn: conn} do
      [user, other] = insert_list(2, :user)
      create_attrs = %{"followee_id" => other.id, "follower_id" => user.id}

      conn =
        post(conn, Routes.api_user_followee_path(conn, :create, other), followee: create_attrs)

      assert json_response(conn, 403)["errors"]["detail"] =~
               "not authorized to view this resource"
    end
  end

  describe "delete followees" do
    setup [:add_token_to_conn]

    test "deletes a followee if follower is current_user", %{conn: conn, user: user} do
      other = insert(:user)

      {:ok, user_connection} =
        UserConnections.create_user_connection(%{
          "followee_id" => other.id,
          "follower_id" => user.id
        })

      conn = delete(conn, Routes.api_user_followee_path(conn, :delete, other, user_connection))
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn ->
        UserConnections.get_user_connection!(%{
          "followee_id" => other.id,
          "follower_id" => user.id
        })
      end
    end

    test "cannot delete a followee if follower is not current_user", %{conn: conn} do
      [user, other] = insert_list(2, :user)

      {:ok, user_connection} =
        UserConnections.create_user_connection(%{
          "followee_id" => other.id,
          "follower_id" => user.id
        })

      conn = delete(conn, Routes.api_user_followee_path(conn, :delete, other, user_connection))

      assert json_response(conn, 403)["errors"]["detail"] =~
               "not authorized to view this resource"
    end
  end
end
