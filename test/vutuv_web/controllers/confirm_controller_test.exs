defmodule VutuvWeb.ConfirmControllerTest do
  use VutuvWeb.ConnCase

  import VutuvWeb.AuthTestHelpers

  alias Vutuv.Accounts

  setup %{conn: conn} do
    conn = conn |> bypass_through(Vutuv.Router, :browser) |> get("/")
    user = add_user("arthur@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "enter code resource" do
    test "renders form to enter code / totp", %{conn: conn} do
      conn = get(conn, Routes.confirm_path(conn, :new, email: "arthur@example.com"))
      assert html_response(conn, 200) =~ "Enter that code below"
    end
  end

  describe "confirmation using otp" do
    test "confirmation succeeds", %{conn: conn, user: user} do
      user_credential = Accounts.get_user_credential(%{"user_id" => user.id})
      code = VutuvWeb.Auth.Otp.create(user_credential.otp_secret)
      attrs = %{"email" => "arthur@example.com", "code" => code}
      conn = post(conn, Routes.confirm_path(conn, :create), confirm: attrs)
      assert redirected_to(conn) == Routes.session_path(conn, :new)
      user_credential = Accounts.get_user_credential(%{"email" => "arthur@example.com"})
      assert user_credential.confirmed
    end

    test "confirmation fails", %{conn: conn} do
      code = "123456"
      attrs = %{"email" => "arthur@example.com", "code" => code}
      conn = post(conn, Routes.confirm_path(conn, :create), confirm: attrs)
      assert html_response(conn, 200) =~ "Enter that code below"
      user_credential = Accounts.get_user_credential(%{"email" => "arthur@example.com"})
      refute user_credential.confirmed
    end
  end
end
