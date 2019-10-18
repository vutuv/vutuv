defmodule Vutuv.UserConnectionsTest do
  use Vutuv.DataCase

  import Vutuv.Factory

  alias Vutuv.{
    UserConnections,
    UserConnections.UserConnection
  }

  describe "reads user connections" do
    test "gets a user_connection" do
      [user_1, user_2] = insert_list(2, :user)

      UserConnections.create_user_connection(%{
        "followee_id" => user_1.id,
        "follower_id" => user_2.id
      })

      assert %UserConnection{} =
               UserConnections.get_user_connection!(%{
                 "followee_id" => user_1.id,
                 "follower_id" => user_2.id
               })

      assert_raise Ecto.NoResultsError, fn ->
        UserConnections.get_user_connection!(%{
          "followee_id" => user_2.id,
          "follower_id" => user_1.id
        })
      end
    end
  end

  describe "writes user connections" do
    test "creates a user_connection" do
      [user_1, user_2] = insert_list(2, :user)

      assert {:ok, %UserConnection{}} =
               UserConnections.create_user_connection(%{
                 "followee_id" => user_1.id,
                 "follower_id" => user_2.id
               })

      assert %UserConnection{} =
               UserConnections.get_user_connection!(%{
                 "followee_id" => user_1.id,
                 "follower_id" => user_2.id
               })

      assert_raise Ecto.NoResultsError, fn ->
        UserConnections.get_user_connection!(%{
          "followee_id" => user_2.id,
          "follower_id" => user_1.id
        })
      end
    end

    test "user cannot follow self" do
      user = insert(:user)

      assert {:error, %Ecto.Changeset{} = changeset} =
               UserConnections.create_user_connection(%{
                 "followee_id" => user.id,
                 "follower_id" => user.id
               })

      assert %{follower_id: ["cannot follow yourself"]} = errors_on(changeset)
    end
  end

  describe "deletes user connections" do
    test "deletes a user_connection" do
      [user_1, user_2] = insert_list(2, :user)

      UserConnections.create_user_connection(%{
        "followee_id" => user_1.id,
        "follower_id" => user_2.id
      })

      assert %UserConnection{} =
               user_connection =
               UserConnections.get_user_connection!(%{
                 "followee_id" => user_1.id,
                 "follower_id" => user_2.id
               })

      assert {:ok, %UserConnection{}} = UserConnections.delete_user_connection(user_connection)

      assert_raise Ecto.NoResultsError, fn ->
        UserConnections.get_user_connection!(%{
          "followee_id" => user_1.id,
          "follower_id" => user_2.id
        })
      end
    end
  end
end
