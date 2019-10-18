defmodule VutuvWeb.PostControllerTest do
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
    conn = conn |> bypass_through(VutuvWeb.Router, [:browser]) |> get("/")
    user = add_user("igor@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "read posts" do
    test "lists a user's public posts", %{conn: conn, user: user} do
      post_1 = insert(:post, %{user: user})
      post_2 = insert(:post, %{user: user, visibility_level: "public"})
      conn = get(conn, Routes.user_post_path(conn, :index, user))
      response = html_response(conn, 200)
      refute response =~ escape_html(post_1.title)
      assert response =~ escape_html(post_2.title)
    end

    test "lists all a user's visible posts - including for followers", %{conn: conn, user: user} do
      post_1 = insert(:post, %{user: user, visibility_level: "public"})
      post_2 = insert(:post, %{user: user, visibility_level: "followers"})
      other = add_user("froderick@example.com")

      UserConnections.create_user_connection(%{
        "followee_id" => user.id,
        "follower_id" => other.id
      })

      conn = conn |> add_session(other) |> send_resp(:ok, "/")
      conn = get(conn, Routes.user_post_path(conn, :index, user))
      response = html_response(conn, 200)
      assert response =~ escape_html(post_1.title)
      assert response =~ escape_html(post_2.title)
    end

    test "lists private posts for current_user", %{conn: conn, user: user} do
      post = insert(:post, %{user: user})
      assert post.visibility_level == "private"
      new_conn = get(conn, Routes.user_post_path(conn, :index, user))
      refute html_response(new_conn, 200) =~ escape_html(post.title)
      conn = conn |> add_session(user) |> send_resp(:ok, "/")
      conn = get(conn, Routes.user_post_path(conn, :index, user))
      assert html_response(conn, 200) =~ escape_html(post.title)
    end

    test "shows a specific public post", %{conn: conn, user: user} do
      post = insert(:post, %{user: user, visibility_level: "public"})
      conn = get(conn, Routes.user_post_path(conn, :show, user, post))
      assert html_response(conn, 200) =~ escape_html(post.title)
    end

    test "shows a post visible to followers", %{conn: conn, user: user} do
      post = insert(:post, %{user: user, visibility_level: "followers"})

      assert_error_sent 404, fn ->
        get(conn, Routes.user_post_path(conn, :show, user, post))
      end

      other = add_user("froderick@example.com")

      UserConnections.create_user_connection(%{
        "followee_id" => user.id,
        "follower_id" => other.id
      })

      conn = conn |> add_session(other) |> send_resp(:ok, "/")
      conn = get(conn, Routes.user_post_path(conn, :show, user, post))
      assert html_response(conn, 200) =~ escape_html(post.title)
    end

    test "shows a private post for current_user", %{conn: conn, user: user} do
      post = insert(:post, %{user: user})
      assert post.visibility_level == "private"

      assert_error_sent 404, fn ->
        get(conn, Routes.user_post_path(conn, :show, user, post))
      end

      conn = conn |> add_session(user) |> send_resp(:ok, "/")
      conn = get(conn, Routes.user_post_path(conn, :show, user, post))
      assert html_response(conn, 200) =~ escape_html(post.title)
    end
  end

  describe "renders forms" do
    setup [:add_session_to_conn]

    test "new post form", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_post_path(conn, :new, user))
      assert html_response(conn, 200) =~ "New post"
    end

    test "edit post form", %{conn: conn, user: user} do
      post = insert(:post, %{user: user})
      conn = get(conn, Routes.user_post_path(conn, :edit, user, post))
      assert html_response(conn, 200) =~ "Edit post"
    end
  end

  describe "write posts" do
    setup [:add_session_to_conn]

    test "create post with valid data", %{conn: conn, user: user} do
      conn = post(conn, Routes.user_post_path(conn, :create, user), post: @create_attrs)
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_post_path(conn, :show, user, id)
      assert get_flash(conn, :info) =~ "created successfully"
    end

    test "does not create post when data is invalid", %{conn: conn, user: user} do
      conn = post(conn, Routes.user_post_path(conn, :create, user), post: %{"body" => ""})
      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end

    test "update post with valid data", %{conn: conn, user: user} do
      post = insert(:post, %{user: user})
      conn = put(conn, Routes.user_post_path(conn, :update, user, post), post: @update_attrs)
      assert redirected_to(conn) == Routes.user_post_path(conn, :show, user, post)
      assert get_flash(conn, :info) =~ "updated successfully"
      post = Publications.get_post!(user, post.id)
      assert post.visibility_level == "public"
    end

    test "does not update post when data is invalid", %{conn: conn, user: user} do
      post = insert(:post, %{user: user})
      too_long = String.duplicate("toooo long", 15_000) <> "a"

      conn =
        put(conn, Routes.user_post_path(conn, :update, user, post), post: %{"body" => too_long})

      assert html_response(conn, 200) =~ "should be at most 150000 character"
    end
  end

  describe "delete post" do
    setup [:add_session_to_conn]

    test "can delete chosen post", %{conn: conn, user: user} do
      post = insert(:post, %{user: user})
      conn = delete(conn, Routes.user_post_path(conn, :delete, user, post))
      assert redirected_to(conn) == Routes.user_post_path(conn, :index, user)
      assert get_flash(conn, :info) =~ "deleted successfully"
      assert_raise Ecto.NoResultsError, fn -> Publications.get_post!(user, post.id) end
    end

    test "cannot delete another user's post", %{conn: conn, user: user} do
      other = add_user("raymond@example.com")
      post = insert(:post, %{user: other})

      assert_error_sent 404, fn ->
        delete(conn, Routes.user_post_path(conn, :delete, user, post))
      end

      assert Publications.get_post!(other, post.id)
    end
  end
end
