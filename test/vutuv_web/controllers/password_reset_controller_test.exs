defmodule VutuvWeb.PasswordResetControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.Accounts

  setup %{conn: conn} do
    conn = conn |> bypass_through(VutuvWeb.Router, :browser) |> get("/")
    user = add_reset_user("gladys@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "request password reset" do
    test "user create a password reset request", %{conn: conn} do
      email = "gladys@example.com"

      conn =
        post(conn, Routes.password_reset_path(conn, :create_request),
          password_reset: %{"email" => email}
        )

      assert redirected_to(conn) == Routes.password_reset_path(conn, :new, email: email)
      user_credential = Accounts.get_user_credential(%{"email" => "gladys@example.com"})
      assert user_credential.password_resettable == true
    end
  end

  describe "enter code resource" do
    test "renders form to enter code / totp", %{conn: conn} do
      conn = get(conn, Routes.password_reset_path(conn, :new, email: "gladys@example.com"))
      assert html_response(conn, 200) =~ "Enter that code below"
    end
  end

  describe "edit password form" do
    test "does not render form unless redirected from create", %{conn: conn} do
      conn = get(conn, Routes.password_reset_path(conn, :edit, email: "gladys@example.com"))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  describe "update password" do
    setup [:update_session, :update_password_reset_status]

    test "password is updated", %{conn: conn, user_credential: user_credential} do
      attrs = %{"email" => "gladys@example.com", "password" => "^hEsdg*F899"}
      conn = put(conn, Routes.password_reset_path(conn, :update), password_reset: attrs)
      assert redirected_to(conn) == Routes.session_path(conn, :new)
      user_credential_1 = Accounts.get_user_credential(%{"email" => "gladys@example.com"})
      assert user_credential_1.password_resettable == false
      assert user_credential.password_hash != user_credential_1.password_hash
    end

    test "weak password is not updated", %{conn: conn, user_credential: user_credential} do
      attrs = %{"email" => "gladys@example.com", "password" => "password"}
      conn = put(conn, Routes.password_reset_path(conn, :update), password_reset: attrs)
      assert html_response(conn, 200) =~ "password you have chosen is weak"
      user_credential_1 = Accounts.get_user_credential(%{"email" => "gladys@example.com"})
      assert user_credential.password_hash == user_credential_1.password_hash
    end

    test "sessions are deleted when user updates password", %{conn: conn, user: user} do
      conn = add_session(conn, user)
      assert get_session(conn, :phauxth_session_id)
      attrs = %{"email" => "gladys@example.com", "password" => "^hEsdg*F899"}
      conn = put(conn, Routes.password_reset_path(conn, :update), password_reset: attrs)
      refute get_session(conn, :phauxth_session_id)
    end

    test "password is not updated if sent_at value has expired", %{
      conn: conn,
      user_credential: user_credential
    } do
      Accounts.set_password_reset_status(user_credential, %{
        password_reset_sent_at: DateTime.add(DateTime.truncate(DateTime.utc_now(), :second), -700)
      })

      attrs = %{"email" => "gladys@example.com", "password" => "^hEsdg*F899"}
      conn = put(conn, Routes.password_reset_path(conn, :update), password_reset: attrs)
      assert redirected_to(conn) == Routes.session_path(conn, :new)
      assert get_flash(conn, :error) =~ "not authorized to view this page"
      user_credential_1 = Accounts.get_user_credential(%{"email" => "gladys@example.com"})
      assert user_credential.password_hash == user_credential_1.password_hash
    end
  end

  describe "rate limiting for email verification stage" do
    setup [:update_session, :update_password_reset_status]

    @tag :rate_limiting
    test "login is blocked after user_name limit (2 every 90 seconds) is reached", %{conn: conn} do
      for _ <- 1..2 do
        attrs = %{"email" => "gladys@example.com", "code" => "123456"}
        conn = post(conn, Routes.password_reset_path(conn, :create), password_reset: attrs)
        assert html_response(conn, 200) =~ "Enter that code below"
      end

      attrs = %{"email" => "gladys@example.com", "code" => "123456"}
      conn = post(conn, Routes.password_reset_path(conn, :create), password_reset: attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :new)
      assert get_flash(conn, :error) == "Too many requests. Please try again later."
    end

    @tag :rate_limiting
    test "count is reset after successful login", %{conn: conn, user: user} do
      attrs = %{"email" => "gladys@example.com", "code" => "123456"}
      conn = post(conn, Routes.password_reset_path(conn, :create), password_reset: attrs)
      user_credential = Accounts.get_user_credential!(%{"user_id" => user.id})
      code = VutuvWeb.Auth.Otp.create(user_credential.otp_secret)
      attrs = %{"email" => "gladys@example.com", "code" => code}
      conn = post(conn, Routes.password_reset_path(conn, :create), password_reset: attrs)

      assert redirected_to(conn) ==
               Routes.password_reset_path(conn, :edit, email: "gladys@example.com")

      assert {:allow, 1} = Hammer.check_rate("gladys@example.com:/password_resets", 90_000, 2)
    end
  end

  defp update_session(%{conn: conn}) do
    conn = put_session(conn, :password_reset, true)
    {:ok, %{conn: conn}}
  end

  defp update_password_reset_status(%{conn: conn}) do
    user_credential = Accounts.get_user_credential(%{"email" => "gladys@example.com"})

    Accounts.set_password_reset_status(user_credential, %{
      password_reset_sent_at: DateTime.truncate(DateTime.utc_now(), :second),
      password_resettable: true
    })

    {:ok, %{conn: conn, user_credential: user_credential}}
  end
end
