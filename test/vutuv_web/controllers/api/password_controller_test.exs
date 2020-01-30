defmodule VutuvWeb.Api.PasswordControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.Accounts

  @create_attrs %{
    "email" => "doug@example.com",
    "old_password" => "reallyHard2gue$$",
    "password" => "tWpYvp88"
  }

  setup %{conn: conn} do
    user = add_user("doug@example.com")
    conn = conn |> add_token_conn(user)
    {:ok, %{conn: conn, user: user}}
  end

  describe "update password" do
    test "user can update password", %{conn: conn, user: user} do
      user_credential = Accounts.get_user_credential(%{"user_id" => user.id})

      conn =
        post(conn, Routes.api_user_password_path(conn, :create, user), password: @create_attrs)

      assert json_response(conn, 200)["info"]["detail"] =~ "password has been updated"
      user_credential_1 = Accounts.get_user_credential(%{"user_id" => user.id})
      assert user_credential.password_hash != user_credential_1.password_hash
    end

    test "weak password is not updated", %{conn: conn, user: user} do
      attrs = Map.merge(@create_attrs, %{"password" => "password"})
      conn = post(conn, Routes.api_user_password_path(conn, :create, user), password: attrs)
      assert [message] = json_response(conn, 422)["errors"]["password"]
      assert message =~ "password you have chosen is weak"
    end

    test "cannot update password if old password is incorrect", %{conn: conn, user: user} do
      attrs = Map.merge(@create_attrs, %{"old_password" => "password"})
      conn = post(conn, Routes.api_user_password_path(conn, :create, user), password: attrs)
      assert json_response(conn, 401)["errors"]["detail"] =~ "Current password is incorrect"
    end
  end
end
