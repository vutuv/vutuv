defmodule VutuvWeb.UserControllerTest do
  use VutuvWeb.ConnCase

  import VutuvWeb.AuthTestHelpers
  alias Vutuv.Accounts

  @create_attrs %{email: "bill@example.com", password: "hard2guess"}
  @update_attrs %{email: "william@example.com"}
  @invalid_attrs %{email: nil}

  setup %{conn: conn} = config do
    conn = conn |> bypass_through(VutuvWeb.Router, [:browser]) |> get("/")

    if email = config[:login] do
      user = add_user(email)
      other = add_user("tony@example.com")
      conn = conn |> add_session(user) |> send_resp(:ok, "/")
      {:ok, %{conn: conn, user: user, other: other}}
    else
      {:ok, %{conn: conn}}
    end
  end

  describe "index" do
    @tag login: "reg@example.com"
    test "lists all entries on index", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Users"
    end

    test "renders /users error for unauthorized user", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  describe "renders forms" do
    test "renders form for new users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "Sign up"
    end

    @tag login: "reg@example.com"
    test "new route redirects to show if user is logged in", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
    end

    @tag login: "reg@example.com"
    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "show user resource" do
    @tag login: "reg@example.com"
    test "show chosen user's page", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "Show User"
    end
  end

  describe "create user" do
    test "creates user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end

    test "does not create user and renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Sign up"
    end
  end

  @tag :skip
  describe "updates user" do
    @tag login: "reg@example.com"
    test "updates chosen user when data is valid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      updated_user = Accounts.get_user(user.id)
      assert updated_user.email == "william@example.com"
      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "william@example.com"
    end

    @tag login: "reg@example.com"
    test "does not update chosen user and renders errors when data is invalid", %{
      conn: conn,
      user: user
    } do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "delete user" do
    @tag login: "reg@example.com"
    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
      refute Accounts.get_user(user.id)
    end

    @tag login: "reg@example.com"
    test "cannot delete other user", %{conn: conn, user: user, other: other} do
      conn = delete(conn, Routes.user_path(conn, :delete, other))
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      assert Accounts.get_user(other.id)
    end
  end
end
