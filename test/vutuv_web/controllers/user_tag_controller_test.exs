defmodule VutuvWeb.UserTagControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.Tags

  setup %{conn: conn} do
    conn = conn |> bypass_through(VutuvWeb.Router, [:browser]) |> get("/")
    user = add_user("igor@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "read user_tags" do
    test "list a user's user_tags", %{conn: conn, user: user} do
      user_tag = insert(:user_tag, %{user: user})
      conn = get(conn, Routes.user_tag_path(conn, :index, user))
      assert html_response(conn, 200) =~ user_tag.tag.name
    end
  end

  describe "renders forms" do
    setup [:add_session_to_conn]

    test "new user_tag form", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_tag_path(conn, :new, user))
      assert html_response(conn, 200) =~ "New user tag"
    end
  end

  describe "write user_tags" do
    setup [:add_session_to_conn]

    test "create user_tag with valid data", %{conn: conn, user: user} do
      create_attrs = %{"name" => "C++"}
      conn = post(conn, Routes.user_tag_path(conn, :create, user), user_tag: create_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      assert get_flash(conn, :info) =~ "created successfully"
    end

    test "does not create user_tag when data is invalid", %{conn: conn, user: user} do
      conn = post(conn, Routes.user_tag_path(conn, :create, user), user_tag: %{"name" => ""})
      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end
  end

  describe "delete user_tag" do
    setup [:add_session_to_conn]

    test "can delete chosen user_tag", %{conn: conn, user: user} do
      user_tag = insert(:user_tag, %{user: user})
      conn = delete(conn, Routes.user_tag_path(conn, :delete, user, user_tag))
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      assert get_flash(conn, :info) =~ "deleted successfully"
      assert_raise Ecto.NoResultsError, fn -> Tags.get_user_tag!(user, user_tag.id) end
    end

    test "cannot delete another user's user_tag", %{conn: conn, user: user} do
      other = add_user("raymond@example.com")
      user_tag = insert(:user_tag, %{user: other})

      assert_error_sent 404, fn ->
        delete(conn, Routes.user_tag_path(conn, :delete, user, user_tag))
      end

      assert Tags.get_user_tag!(other, user_tag.id)
    end
  end
end
