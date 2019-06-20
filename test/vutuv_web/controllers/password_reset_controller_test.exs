defmodule VutuvWeb.PasswordResetControllerTest do
  use VutuvWeb.ConnCase

  import VutuvWeb.AuthTestHelpers

  setup %{conn: conn} do
    conn = conn |> bypass_through(VutuvWeb.Router, :browser) |> get("/")
    user = add_reset_user("gladys@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "request password reset" do
    test "user can create a password reset request", %{conn: _conn} do
    end

    test "create function fails for no user", %{conn: _conn} do
    end
  end

  describe "enter code resource" do
    test "renders form to enter code / totp", %{conn: conn} do
      conn = get(conn, Routes.password_reset_path(conn, :new, email: "gladys@example.com"))
      assert html_response(conn, 200) =~ "Reset password"
    end

    test "after requesting a password reset, user is redirected to enter code page", %{
      conn: _conn,
      user: _user
    } do
    end
  end

  describe "reset password using otp" do
    test "succeeds for correct code", %{conn: _conn, user: _user} do
    end

    test "fails for incorrect code", %{conn: _conn} do
    end

    test "sessions are deleted when user updates password", %{conn: _conn, user: _user} do
    end
  end
end
