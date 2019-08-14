defmodule VutuvWeb.EmailTest do
  use ExUnit.Case
  use Bamboo.Test

  alias VutuvWeb.{Auth.Otp, Email}

  setup do
    email = "deirdre@example.com"
    secret = OneTimePassEcto.Base.gen_secret()
    {:ok, %{email: email, code: Otp.create(secret)}}
  end

  describe "verification request" do
    test "sends verification request email", %{email: email, code: code} do
      sent_email = Email.verify_request(email, code)
      assert sent_email.subject =~ "Verify your email"
      assert sent_email.text_body =~ "Enter the following verification code"
      assert_delivered_email(Email.verify_request(email, code))
    end

    test "sends duplicate email message", %{email: email} do
      sent_email = Email.verify_request(email, nil)
      assert sent_email.subject =~ "Verify your email"
      assert sent_email.text_body =~ "this email address is already in use"
      assert_delivered_email(Email.verify_request(email, nil))
    end
  end

  describe "reset password request" do
    test "sends reset password request email", %{email: email, code: code} do
      sent_email = Email.reset_request(email, code)
      assert sent_email.subject =~ "Reset your password"
      assert sent_email.text_body =~ "Enter the following password reset code"
      assert_delivered_email(Email.reset_request(email, code))
    end

    test "sends no user found message" do
      sent_email = Email.reset_request("gladys@example.com", nil)
      assert sent_email.text_body =~ "but no user is associated with the email you provided"
    end
  end

  describe "completed emails" do
    test "sends receipt verification email", %{email: email} do
      sent_email = Email.verify_success(email)
      assert sent_email.text_body =~ "email has been verified"
      assert_delivered_email(Email.verify_success(email))
    end

    test "sends password reset email", %{email: email} do
      sent_email = Email.reset_success(email)
      assert sent_email.text_body =~ "password has been reset"
      assert_delivered_email(Email.reset_success(email))
    end
  end
end
