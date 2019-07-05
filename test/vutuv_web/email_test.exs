defmodule VutuvWeb.EmailTest do
  use ExUnit.Case
  use Bamboo.Test

  alias VutuvWeb.{Auth.Otp, Email}

  setup do
    email = "deirdre@example.com"
    secret = OneTimePassEcto.Base.gen_secret()
    {:ok, %{email: email, code: Otp.create(secret)}}
  end

  test "sends confirmation request email", %{email: email, code: code} do
    sent_email = Email.confirm_request(email, code)
    assert sent_email.subject =~ "Confirm your account"
    assert sent_email.text_body =~ "Enter the following confirmation code"
    assert_delivered_email(Email.confirm_request(email, code))
  end

  test "sends no user found message for password reset attempt" do
    sent_email = Email.reset_request("gladys@example.com", nil)
    assert sent_email.text_body =~ "but no user is associated with the email you provided"
  end

  test "sends reset password request email", %{email: email, code: code} do
    sent_email = Email.reset_request(email, code)
    assert sent_email.subject =~ "Reset your password"
    assert sent_email.text_body =~ "Enter the following password reset code"
    assert_delivered_email(Email.reset_request(email, code))
  end

  test "sends receipt confirmation email", %{email: email} do
    sent_email = Email.confirm_success(email)
    assert sent_email.text_body =~ "account has been confirmed"
    assert_delivered_email(Email.confirm_success(email))
  end

  test "sends password reset email", %{email: email} do
    sent_email = Email.reset_success(email)
    assert sent_email.text_body =~ "password has been reset"
    assert_delivered_email(Email.reset_success(email))
  end
end
