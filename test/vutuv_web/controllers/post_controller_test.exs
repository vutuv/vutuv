defmodule VutuvWeb.PostControllerTest do
  use VutuvWeb.ConnCase

  import Vutuv.Factory
  import VutuvWeb.AuthTestHelpers

  alias Vutuv.Socials

  @create_post_attrs %{
    body: Faker.Company.bs(),
    title: Faker.Company.name(),
    visibility_level: "private"
  }
  @update_post_attrs %{
    visibility_level: "public"
  }

  setup %{conn: conn} do
    conn = conn |> bypass_through(VutuvWeb.Router, [:browser]) |> get("/")
    user = add_user("igor@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "read posts" do
    test "lists all of a user's posts", %{conn: conn, user: user} do
      _post = insert(:post, %{user: user})
      conn = get(conn, Routes.user_post_path(conn, :index, user))
      assert html_response(conn, 200) =~ dirty_escape(user.full_name)
    end

    test "shows a specific post", %{conn: conn, user: user} do
      post = insert(:post, %{user: user})
      conn = get(conn, Routes.user_post_path(conn, :show, user, post))
      assert html_response(conn, 200) =~ dirty_escape(post.title)
    end
  end

  describe "renders forms" do
    setup [:add_user_session]

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
    setup [:add_user_session]

    test "can create post with valid data", %{conn: conn, user: user} do
      conn = post(conn, Routes.user_post_path(conn, :create, user), post: @create_post_attrs)
      assert redirected_to(conn) == Routes.user_post_path(conn, :index, user)
      assert get_flash(conn, :info) =~ "created successfully"
    end

    test "does not create post when data is invalid", %{conn: conn, user: user} do
      conn = post(conn, Routes.user_post_path(conn, :create, user), post: %{"body" => ""})
      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end

    test "can update post with valid data", %{conn: conn, user: user} do
      post = insert(:post, %{user: user})
      conn = put(conn, Routes.user_post_path(conn, :update, user, post), post: @update_post_attrs)
      assert redirected_to(conn) == Routes.user_post_path(conn, :show, user, post)
      assert get_flash(conn, :info) =~ "updated successfully"
      post = Socials.get_post(user, %{"id" => post.id})
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
    setup [:add_user_session]

    test "can delete chosen post", %{conn: conn, user: user} do
      post = insert(:post, %{user: user})
      conn = delete(conn, Routes.user_post_path(conn, :delete, user, post))
      assert redirected_to(conn) == Routes.user_post_path(conn, :index, user)
      assert get_flash(conn, :info) =~ "deleted successfully"
      refute Socials.get_post(user, %{"id" => post.id})
    end

    test "cannot delete another user's post", %{conn: conn, user: user} do
      other = add_user("raymond@example.com")
      post = insert(:post, %{user: other})
      conn = delete(conn, Routes.user_post_path(conn, :delete, user, post))
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      assert get_flash(conn, :error) =~ "not authorized"
      assert Socials.get_post(other, %{"id" => post.id})
    end
  end

  defp add_user_session(%{conn: conn, user: user}) do
    conn = conn |> add_session(user) |> send_resp(:ok, "/")
    {:ok, %{conn: conn, user: user}}
  end

  # helper function for checking safe html response
  defp dirty_escape(input) do
    String.replace(input, "'", "&#39;")
  end
end
