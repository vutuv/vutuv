defmodule VutuvWeb.Api.VerificationControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.Accounts

  setup %{conn: conn} do
    user = add_user("maria@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "confirmation using otp" do
    test "confirmation succeeds", %{conn: conn, user: user} do
      user_credential = Accounts.get_user_credential!(%{"user_id" => user.id})
      code = VutuvWeb.Auth.Otp.create(user_credential.otp_secret)
      attrs = %{"email" => "maria@example.com", "code" => code}
      conn = post(conn, Routes.api_verification_path(conn, :create), verify: attrs)
      assert json_response(conn, 201)["info"]["detail"] =~ "email has been verified"
      user_credential = Accounts.get_user_credential!(%{"email" => "maria@example.com"})
      assert user_credential.confirmed
    end

    test "confirmation fails", %{conn: conn} do
      attrs = %{"email" => "maria@example.com", "code" => "123456"}
      conn = post(conn, Routes.api_verification_path(conn, :create), verify: attrs)
      assert json_response(conn, 401)["errors"]["detail"] =~ "Invalid code"
      user_credential = Accounts.get_user_credential!(%{"email" => "maria@example.com"})
      refute user_credential.confirmed
    end

    test "code can be resent", %{conn: conn} do
      conn =
        post(conn, Routes.api_verification_path(conn, :send_code), email: "maria@example.com")

      assert json_response(conn, 200)["info"]["detail"] =~ "code has been sent"
    end
  end

  describe "rate limiting for verify email" do
    @tag :rate_limiting
    test "login is blocked after user_name limit (2 every 90 seconds) is reached", %{conn: conn} do
      for _ <- 1..2 do
        attrs = %{"email" => "maria@example.com", "code" => "123456"}
        conn = post(conn, Routes.api_verification_path(conn, :create), verify: attrs)
        assert json_response(conn, 401)["errors"]["detail"] =~ "Invalid code"
      end

      attrs = %{"email" => "maria@example.com", "code" => "123456"}
      conn = post(conn, Routes.api_verification_path(conn, :create), verify: attrs)
      assert json_response(conn, 429)["errors"]["detail"] =~ "Too many requests."
    end

    @tag :rate_limiting
    test "count is reset after successful login", %{conn: conn, user: user} do
      attrs = %{"email" => "maria@example.com", "code" => "123456"}
      conn = post(conn, Routes.api_verification_path(conn, :create), verify: attrs)
      user_credential = Accounts.get_user_credential!(%{"user_id" => user.id})
      code = VutuvWeb.Auth.Otp.create(user_credential.otp_secret)
      attrs = %{"email" => "maria@example.com", "code" => code}
      conn = post(conn, Routes.api_verification_path(conn, :create), verify: attrs)
      assert json_response(conn, 201)["info"]["detail"] =~ "email has been verified"
      assert {:allow, 1} = Hammer.check_rate("maria@example.com:/verifications", 90_000, 2)
    end
  end
end
