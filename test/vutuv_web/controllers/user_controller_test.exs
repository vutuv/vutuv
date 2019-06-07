defmodule VutuvWeb.UserControllerTest do
  use VutuvWeb.ConnCase

  import VutuvWeb.AuthTestHelpers
  alias Vutuv.Accounts

  @create_attrs %{
    "email" => "bill@example.com",
    "password" => "reallyHard2gue$$",
    "profile" => %{
      "gender" => "male",
      "full_name" => "bill shakespeare"
    }
  }
  @invalid_attrs %{email: nil}

  setup %{conn: conn} do
    conn = conn |> bypass_through(VutuvWeb.Router, [:browser]) |> get("/")
    {:ok, %{conn: conn}}
  end

  describe "read user data" do
    test "lists all entries on index", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing users"
    end

    test "show chosen user's page", %{conn: conn} do
      user = add_user("reg@example.com")
      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ ~r/Show user(.|\n)*Edit email/
    end
  end

  describe "renders forms" do
    setup [:add_user_session]

    test "renders form for new users" do
      conn = build_conn()
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "Sign up"
    end

    test "new route redirects to show if user is logged in", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
    end

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit user"
    end
  end

  describe "create user data" do
    test "successful when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end

    test "fails and renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Sign up"
    end
  end

  describe "update user data" do
    setup [:add_user_session]

    test "successful when data is valid", %{conn: conn, user: user} do
      attrs = %{"profile" => %{"full_name" => "Raymond Luxury Yacht"}}
      conn = put(conn, Routes.user_path(conn, :update, user), user: attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      updated_user = Accounts.get_user(user.id)
      assert updated_user.profile.full_name == "Raymond Luxury Yacht"
      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "Raymond Luxury Yacht"
    end

    test "fails when data is invalid", %{conn: conn, user: user} do
      attrs = %{"profile" => %{"honorific_prefix" => String.duplicate("Dr", 42)}}
      conn = put(conn, Routes.user_path(conn, :update, user), user: attrs)
      assert html_response(conn, 200) =~ ~r/Edit user(.|\n)*DrDrDrDrDrDrDrDr/
    end
  end

  describe "delete user" do
    setup [:add_user_session]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
      refute Accounts.get_user(user.id)
    end

    test "cannot delete other user", %{conn: conn, user: user} do
      other = add_user("tony@example.com")
      conn = delete(conn, Routes.user_path(conn, :delete, other))
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      assert Accounts.get_user(other.id)
    end
  end

  defp add_user_session(%{conn: conn}) do
    user = add_user("reg@example.com")
    conn = conn |> add_session(user) |> send_resp(:ok, "/")
    {:ok, %{conn: conn, user: user}}
  end
end
