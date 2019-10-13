defmodule VutuvWeb.VerificationControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.Accounts

  setup %{conn: conn} do
    conn = conn |> bypass_through(Vutuv.Router, :browser) |> get("/")
    user = add_user("arthur@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "enter code resource" do
    test "renders form to enter code / totp", %{conn: conn} do
      conn = get(conn, Routes.verification_path(conn, :new, email: "arthur@example.com"))
      assert html_response(conn, 200) =~ "Enter that code below"
    end

    test "returns 404 if email has not been registered", %{conn: conn} do
      assert_error_sent 404, fn ->
        get(conn, Routes.verification_path(conn, :new, email: "froderick@example.com"))
      end
    end

    test "returns 404 if email has already been verified", %{conn: conn} do
      add_user_confirmed("froderick@example.com")

      assert_error_sent 404, fn ->
        get(conn, Routes.verification_path(conn, :new, email: "froderick@example.com"))
      end
    end
  end

  describe "confirmation using otp" do
    test "confirmation succeeds", %{conn: conn, user: user} do
      user_credential = Accounts.get_user_credential!(%{"user_id" => user.id})
      code = VutuvWeb.Auth.Otp.create(user_credential.otp_secret)
      attrs = %{"email" => "arthur@example.com", "code" => code}
      conn = post(conn, Routes.verification_path(conn, :create), verify: attrs)
      assert redirected_to(conn) == Routes.session_path(conn, :new)
      user_credential = Accounts.get_user_credential!(%{"email" => "arthur@example.com"})
      assert user_credential.confirmed
    end

    test "confirmation fails", %{conn: conn} do
      code = "123456"
      attrs = %{"email" => "arthur@example.com", "code" => code}
      conn = post(conn, Routes.verification_path(conn, :create), verify: attrs)
      assert html_response(conn, 200) =~ "Enter that code below"
      user_credential = Accounts.get_user_credential!(%{"email" => "arthur@example.com"})
      refute user_credential.confirmed
    end

    test "code can be resent", %{conn: conn} do
      conn = post(conn, Routes.verification_path(conn, :send_code), email: "arthur@example.com")

      assert redirected_to(conn) ==
               Routes.verification_path(conn, :new, email: "arthur@example.com")
    end
  end
end
