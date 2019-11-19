defmodule VutuvWeb.Api.PasswordResetControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.Accounts
  alias VutuvWeb.Auth.Token

  setup %{conn: conn} do
    user = add_reset_user("gladys@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "request password reset" do
    test "user create a password reset request", %{conn: conn} do
      email = "gladys@example.com"

      conn =
        post(conn, Routes.api_password_reset_path(conn, :create_request),
          password_reset: %{"email" => email}
        )

      assert json_response(conn, 201)["info"]["detail"] =~ "Check your inbox for instructions"
      user_credential = Accounts.get_user_credential(%{"email" => "gladys@example.com"})
      assert user_credential.password_resettable == true
    end
  end

  describe "submit otp code" do
    test "key is sent when code is valid", %{conn: conn, user: user} do
      attrs = get_create_attrs(user, true)
      conn = post(conn, Routes.api_password_reset_path(conn, :create), password_reset: attrs)
      assert json_response(conn, 201)["info"]["detail"] =~ "Code input correctly"
      assert json_response(conn, 201)["info"]["key"]
    end

    test "error sent when code is invalid", %{conn: conn, user: user} do
      attrs = get_create_attrs(user, false)
      conn = post(conn, Routes.api_password_reset_path(conn, :create), password_reset: attrs)
      assert json_response(conn, 401)["errors"]["detail"] =~ "Invalid code"
    end
  end

  describe "update password" do
    setup [:update_password_reset_status]

    test "password is updated", %{conn: conn, key: key, user_credential: user_credential} do
      attrs = %{"email" => "gladys@example.com", "key" => key, "password" => "^hEsdg*F899"}
      conn = put(conn, Routes.api_password_reset_path(conn, :update), password_reset: attrs)
      assert json_response(conn, 200)["info"]["detail"] =~ "password has been reset"
      user_credential_1 = Accounts.get_user_credential(%{"email" => "gladys@example.com"})
      assert user_credential_1.password_resettable == false
      assert user_credential.password_hash != user_credential_1.password_hash
    end

    test "weak password is not updated", %{conn: conn, key: key, user_credential: user_credential} do
      attrs = %{"email" => "gladys@example.com", "key" => key, "password" => "password"}
      conn = put(conn, Routes.api_password_reset_path(conn, :update), password_reset: attrs)
      assert [message] = json_response(conn, 422)["errors"]["password"]
      assert message =~ "password you have chosen is weak"
      user_credential_1 = Accounts.get_user_credential(%{"email" => "gladys@example.com"})
      assert user_credential.password_hash == user_credential_1.password_hash
    end

    test "returns unauthorized if the key is not present or invalid", %{conn: conn} do
      attrs = %{"email" => "gladys@example.com", "password" => "^hEsdg*F899"}
      conn = put(conn, Routes.api_password_reset_path(conn, :update), password_reset: attrs)
      assert json_response(conn, 401)["errors"]["detail"] =~ "need to login"
      attrs = %{"email" => "gladys@example.com", "key" => "garbage", "password" => "^hEsdg*F899"}
      conn = put(conn, Routes.api_password_reset_path(conn, :update), password_reset: attrs)
      assert json_response(conn, 401)["errors"]["detail"] =~ "need to login"
    end

    test "password is not updated if sent_at value has expired", %{
      conn: conn,
      key: key,
      user_credential: user_credential
    } do
      Accounts.set_password_reset_status(user_credential, %{
        password_reset_sent_at: DateTime.add(DateTime.truncate(DateTime.utc_now(), :second), -700)
      })

      attrs = %{"email" => "gladys@example.com", "key" => key, "password" => "^hEsdg*F899"}
      conn = put(conn, Routes.api_password_reset_path(conn, :update), password_reset: attrs)
      assert json_response(conn, 401)["errors"]["detail"] =~ "need to login"
      user_credential_1 = Accounts.get_user_credential(%{"email" => "gladys@example.com"})
      assert user_credential.password_hash == user_credential_1.password_hash
    end
  end

  defp get_create_attrs(user, valid) do
    user_credential = Accounts.get_user_credential!(%{"user_id" => user.id})

    code =
      if valid do
        VutuvWeb.Auth.Otp.create(user_credential.otp_secret)
      else
        "123456"
      end

    Accounts.set_password_reset_status(user_credential, %{
      password_reset_sent_at: DateTime.truncate(DateTime.utc_now(), :second)
    })

    %{"email" => "gladys@example.com", "code" => code}
  end

  defp update_password_reset_status(%{conn: conn}) do
    user_credential = Accounts.get_user_credential(%{"email" => "gladys@example.com"})

    Accounts.set_password_reset_status(user_credential, %{
      password_reset_sent_at: DateTime.truncate(DateTime.utc_now(), :second),
      password_resettable: true
    })

    key = Token.sign(%{"email" => "gladys@example.com"})

    {:ok, %{conn: conn, key: key, user_credential: user_credential}}
  end
end
