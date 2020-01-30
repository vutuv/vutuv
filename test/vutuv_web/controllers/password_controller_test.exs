defmodule VutuvWeb.PasswordControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.Accounts

  @create_attrs %{
    "email" => "dinsdale@example.com",
    "old_password" => "reallyHard2gue$$",
    "password" => "tWpYvp88"
  }

  setup %{conn: conn} do
    conn = conn |> bypass_through(VutuvWeb.Router, :browser) |> get("/")
    user = add_user("dinsdale@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "show change password form" do
    test "authenticated user can see form", %{conn: conn, user: user} do
      conn = conn |> add_session(user) |> send_resp(:ok, "/")
      conn = get(conn, Routes.user_password_path(conn, :new, user))
      assert html_response(conn, 200) =~ "current password and a new password"
    end

    test "user is redirected if not logged in", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_password_path(conn, :new, user))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
      assert get_flash(conn, :error) =~ "need to log in"
    end
  end

  describe "update password" do
    test "user can update password", %{conn: conn, user: user} do
      conn = conn |> add_session(user) |> send_resp(:ok, "/")
      user_credential = Accounts.get_user_credential(%{"user_id" => user.id})
      conn = post(conn, Routes.user_password_path(conn, :create, user), password: @create_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      assert get_flash(conn, :info) =~ "password has been updated"
      user_credential_1 = Accounts.get_user_credential(%{"user_id" => user.id})
      assert user_credential.password_hash != user_credential_1.password_hash
    end

    test "weak password is not updated", %{conn: conn, user: user} do
      conn = conn |> add_session(user) |> send_resp(:ok, "/")
      attrs = Map.merge(@create_attrs, %{"password" => "password"})
      conn = post(conn, Routes.user_password_path(conn, :create, user), password: attrs)
      assert html_response(conn, 200) =~ "password you have chosen is weak"
    end

    test "cannot update password if old password is incorrect", %{conn: conn, user: user} do
      conn = conn |> add_session(user) |> send_resp(:ok, "/")
      attrs = Map.merge(@create_attrs, %{"old_password" => "password"})
      conn = post(conn, Routes.user_password_path(conn, :create, user), password: attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
    end
  end
end
