defmodule VutuvWeb.Api.UserTagControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.Tags

  setup %{conn: conn} do
    user = add_user("igor@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "read user_tags" do
    test "list a user's user_tags", %{conn: conn, user: user} do
      user_tag = insert(:user_tag, %{user: user})
      conn = get(conn, Routes.api_user_tag_path(conn, :index, user))
      assert [new_user_tag] = json_response(conn, 200)["data"]
      assert new_user_tag == single_response(user_tag)
    end
  end

  describe "write user_tags" do
    setup [:add_token_to_conn]

    test "create user_tag with valid data", %{conn: conn, user: user} do
      create_attrs = %{"name" => "C++"}
      conn = post(conn, Routes.api_user_tag_path(conn, :create, user), user_tag: create_attrs)
      assert json_response(conn, 201)["data"]["id"]
      [new_user_tag] = Tags.list_user_tags(user)
      assert new_user_tag.tag.name == "C++"
    end

    test "does not create user_tag when data is invalid", %{conn: conn, user: user} do
      conn = post(conn, Routes.api_user_tag_path(conn, :create, user), user_tag: %{"name" => ""})
      assert json_response(conn, 422)["errors"]["name"] == ["can't be blank"]
    end
  end

  describe "delete user_tag" do
    setup [:add_token_to_conn]

    test "can delete chosen user_tag", %{conn: conn, user: user} do
      user_tag = insert(:user_tag, %{user: user})
      conn = delete(conn, Routes.api_user_tag_path(conn, :delete, user, user_tag))
      assert response(conn, 204)
      assert_raise Ecto.NoResultsError, fn -> Tags.get_user_tag!(user, user_tag.id) end
    end

    test "cannot delete another user's user_tag", %{conn: conn, user: user} do
      other = add_user("raymond@example.com")
      user_tag = insert(:user_tag, %{user: other})

      assert_error_sent 404, fn ->
        delete(conn, Routes.api_user_tag_path(conn, :delete, user, user_tag))
      end

      assert Tags.get_user_tag!(other, user_tag.id)
    end
  end

  defp single_response(%{tag: tag} = user_tag) do
    %{
      "id" => user_tag.id,
      "tag" => %{"description" => tag.description, "name" => tag.name},
      "tag_id" => user_tag.tag_id,
      "user_id" => user_tag.user_id
    }
  end
end
