defmodule VutuvWeb.Api.PostControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.{UserConnections, Publications}

  @create_attrs %{
    body: Faker.Company.bs(),
    title: Faker.Company.name(),
    visibility_level: "private"
  }
  @update_attrs %{
    visibility_level: "public"
  }

  setup %{conn: conn} do
    user = add_user("igor@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "read posts" do
    test "lists a user's public posts", %{conn: conn, user: user} do
      _post_1 = insert(:post, %{user: user})
      post_2 = insert(:post, %{user: user, visibility_level: "public"})
      conn = get(conn, Routes.api_user_post_path(conn, :index, user))
      assert [new_post] = json_response(conn, 200)["data"]
      assert new_post == single_response(post_2)
    end

    test "lists all a user's visible posts - including for followers", %{conn: conn, user: user} do
      post_1 = insert(:post, %{user: user, visibility_level: "public"})
      post_2 = insert(:post, %{user: user, visibility_level: "followers"})
      other = add_user("froderick@example.com")

      UserConnections.create_user_connection(%{
        "followee_id" => user.id,
        "follower_id" => other.id
      })

      conn = add_token_conn(conn, other)
      conn = get(conn, Routes.api_user_post_path(conn, :index, user))
      posts = json_response(conn, 200)["data"]
      [new_post_1, new_post_2] = Enum.sort(posts, &(&1["id"] <= &2["id"]))
      assert new_post_1 == single_response(post_1)
      assert new_post_2 == single_response(post_2)
    end

    test "lists private posts for current_user", %{conn: conn, user: user} do
      post = insert(:post, %{user: user})
      assert post.visibility_level == "private"
      new_conn = get(conn, Routes.api_user_post_path(conn, :index, user))
      assert json_response(new_conn, 200)["data"] == []
      conn = add_token_conn(conn, user)
      conn = get(conn, Routes.api_user_post_path(conn, :index, user))
      assert [new_post] = json_response(conn, 200)["data"]
      assert new_post == single_response(post)
    end

    test "shows a specific public post", %{conn: conn, user: user} do
      post = insert(:post, %{user: user, visibility_level: "public"})
      conn = get(conn, Routes.api_user_post_path(conn, :show, user, post))
      assert json_response(conn, 200)["data"] == single_response(post)
    end

    test "shows a post visible to followers", %{conn: conn, user: user} do
      post = insert(:post, %{user: user, visibility_level: "followers"})

      assert_error_sent 404, fn ->
        get(conn, Routes.api_user_post_path(conn, :show, user, post))
      end

      other = add_user("froderick@example.com")

      UserConnections.create_user_connection(%{
        "followee_id" => user.id,
        "follower_id" => other.id
      })

      conn = add_token_conn(conn, other)
      conn = get(conn, Routes.api_user_post_path(conn, :show, user, post))
      assert json_response(conn, 200)["data"] == single_response(post)
    end

    test "shows a private post for current_user", %{conn: conn, user: user} do
      post = insert(:post, %{user: user})
      assert post.visibility_level == "private"

      assert_error_sent 404, fn ->
        get(conn, Routes.api_user_post_path(conn, :show, user, post))
      end

      conn = add_token_conn(conn, user)
      conn = get(conn, Routes.api_user_post_path(conn, :show, user, post))
      assert json_response(conn, 200)["data"] == single_response(post)
    end
  end

  describe "write posts" do
    setup [:add_token_to_conn]

    test "create post with valid data", %{conn: conn, user: user} do
      conn = post(conn, Routes.api_user_post_path(conn, :create, user), post: @create_attrs)
      assert json_response(conn, 201)["data"]["id"]
      [new_post] = Publications.list_posts(user)
      assert new_post.body == @create_attrs[:body]
      assert new_post.title == @create_attrs[:title]
    end

    test "does not create post when data is invalid", %{conn: conn, user: user} do
      conn = post(conn, Routes.api_user_post_path(conn, :create, user), post: %{"body" => ""})
      assert json_response(conn, 422)["errors"]["body"] == ["can't be blank"]
    end

    test "update post with valid data", %{conn: conn, user: user} do
      post = insert(:post, %{user: user})
      conn = put(conn, Routes.api_user_post_path(conn, :update, user, post), post: @update_attrs)
      assert json_response(conn, 200)["data"]["id"]
      post = Publications.get_post!(user, post.id)
      assert post.visibility_level == "public"
    end

    test "does not update post when data is invalid", %{conn: conn, user: user} do
      post = insert(:post, %{user: user})
      too_long = String.duplicate("toooo long", 15_000) <> "a"

      conn =
        put(conn, Routes.api_user_post_path(conn, :update, user, post),
          post: %{"body" => too_long}
        )

      assert json_response(conn, 422)["errors"]["body"] == [
               "should be at most 150000 character(s)"
             ]
    end
  end

  describe "delete post" do
    setup [:add_token_to_conn]

    test "can delete chosen post", %{conn: conn, user: user} do
      post = insert(:post, %{user: user})
      conn = delete(conn, Routes.api_user_post_path(conn, :delete, user, post))
      assert response(conn, 204)
      assert_raise Ecto.NoResultsError, fn -> Publications.get_post!(user, post.id) end
    end

    test "cannot delete another user's post", %{conn: conn, user: user} do
      other = add_user("raymond@example.com")
      post = insert(:post, %{user: other})

      assert_error_sent 404, fn ->
        delete(conn, Routes.api_user_post_path(conn, :delete, user, post))
      end

      assert Publications.get_post!(other, post.id)
    end
  end

  defp single_response(post) do
    %{
      "id" => post.id,
      "user_id" => post.user_id,
      "body" => post.body,
      "title" => post.title,
      "visibility_level" => post.visibility_level
    }
  end
end
