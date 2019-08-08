defmodule VutuvWeb.PasswordResetControllerTest do
  use VutuvWeb.ConnCase

  import VutuvWeb.AuthTestHelpers

  setup %{conn: conn} do
    conn = conn |> bypass_through(VutuvWeb.Router, :browser) |> get("/")
    user = add_reset_user("gladys@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "request password reset" do
    test "user can create a password reset request", %{conn: conn} do
      email = "gladys@example.com"

      conn =
        post(conn, Routes.password_reset_path(conn, :create_request),
          password_reset: %{"email" => email}
        )

      assert redirected_to(conn) == Routes.password_reset_path(conn, :new, email: email)
    end
  end

  describe "enter code resource" do
    test "renders form to enter code / totp", %{conn: conn} do
      conn = get(conn, Routes.password_reset_path(conn, :new, email: "gladys@example.com"))
      assert html_response(conn, 200) =~ "Enter that code below"
    end
  end

  describe "update password" do
    test "password is updated", %{conn: conn} do
      attrs = %{"email" => "gladys@example.com", "password" => "^hEsdg*F899"}
      conn = put(conn, Routes.password_reset_path(conn, :update), password_reset: attrs)
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end

    test "weak password is not updated", %{conn: conn} do
      attrs = %{"email" => "gladys@example.com", "password" => "password"}
      conn = put(conn, Routes.password_reset_path(conn, :update), password_reset: attrs)
      assert get_flash(conn, :error) =~ "password you have chosen is weak"
    end

    test "sessions are deleted when user updates password", %{conn: conn, user: user} do
      conn = add_session(conn, user)
      assert get_session(conn, :phauxth_session_id)
      attrs = %{"email" => "gladys@example.com", "password" => "^hEsdg*F899"}
      conn = put(conn, Routes.password_reset_path(conn, :update), password_reset: attrs)
      refute get_session(conn, :phauxth_session_id)
    end
  end
end
