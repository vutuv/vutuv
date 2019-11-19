defmodule VutuvWeb.Api.VerificationControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.Accounts

  setup %{conn: conn} do
    user = add_user("arthur@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "confirmation using otp" do
    test "confirmation succeeds", %{conn: conn, user: user} do
      user_credential = Accounts.get_user_credential!(%{"user_id" => user.id})
      code = VutuvWeb.Auth.Otp.create(user_credential.otp_secret)
      attrs = %{"email" => "arthur@example.com", "code" => code}
      conn = post(conn, Routes.api_verification_path(conn, :create), verify: attrs)
      assert json_response(conn, 201)["info"]["detail"] =~ "email has been verified"
      user_credential = Accounts.get_user_credential!(%{"email" => "arthur@example.com"})
      assert user_credential.confirmed
    end

    test "confirmation fails", %{conn: conn} do
      code = "123456"
      attrs = %{"email" => "arthur@example.com", "code" => code}
      conn = post(conn, Routes.api_verification_path(conn, :create), verify: attrs)
      assert json_response(conn, 401)["errors"]["detail"] =~ "Invalid code"
      user_credential = Accounts.get_user_credential!(%{"email" => "arthur@example.com"})
      refute user_credential.confirmed
    end

    test "code can be resent", %{conn: conn} do
      conn =
        post(conn, Routes.api_verification_path(conn, :send_code), email: "arthur@example.com")

      assert json_response(conn, 200)["info"]["detail"] =~ "code has been sent"
    end
  end
end
