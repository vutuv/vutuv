defmodule VutuvWeb.ConfirmControllerTest do
  use VutuvWeb.ConnCase

  import VutuvWeb.AuthTestHelpers

  setup %{conn: conn} do
    conn = conn |> bypass_through(Vutuv.Router, :browser) |> get("/")
    add_user("arthur@example.com")
    {:ok, %{conn: conn}}
  end

  describe "enter code resource" do
    test "renders form to enter code / totp", %{conn: conn} do
      conn = get(conn, Routes.confirm_path(conn, :new, email: "arthur@example.com"))
      assert html_response(conn, 200) =~ "Enter that code here"
    end

    test "upon signup, new user is redirected to enter code page" do
    end

    test "after creating an email, user is redirected to enter code page" do
    end
  end

  describe "confirmation using otp" do
    test "confirmation succeeds" do
    end

    test "confirmation fails" do
    end
  end
end
