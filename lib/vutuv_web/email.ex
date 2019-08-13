defmodule VutuvWeb.Email do
  @moduledoc """
  A module for sending emails to the user.

  This module uses Bamboo to send emails to users.

  ## Bamboo adapters

  For production, Bamboo provides adapters for Mailgun, Mailjet, Mandrill,
  Sendgrid, SMTP, SparkPost, PostageApp, Postmark and Sendcloud. Currently,
  no adapter is configured for use in production.

  For development, Bamboo's local adapter is used, and sent emails can be viewed
  at [http://localhost:4000/sent_emails](http://localhost:4000/sent_emails).

  For tests, Bamboo's test adapter is used.
  """

  import Bamboo.Email
  alias VutuvWeb.Mailer

  @doc """
  An email with a verification link in it.
  """
  def verify_request(address, code) do
    address
    |> base_email()
    |> subject("Verify your email")
    |> add_body(:verify_request, code)
    |> Mailer.deliver_later()
  end

  @doc """
  An email with a link to reset the password.
  """
  def reset_request(address, code) do
    address
    |> base_email()
    |> subject("Reset your password")
    |> add_body(:reset_request, code)
    |> Mailer.deliver_later()
  end

  @doc """
  An email acknowledging that the email has been successfully verified.
  """
  def verify_success(address) do
    address
    |> base_email()
    |> subject("Verified email")
    |> text_body("Your email has been verified.")
    |> Mailer.deliver_later()
  end

  @doc """
  An email acknowledging that the password has been successfully reset.
  """
  def reset_success(address) do
    address
    |> base_email()
    |> subject("Password reset")
    |> text_body("Your password has been reset.")
    |> Mailer.deliver_later()
  end

  defp base_email(address) do
    new_email()
    |> to(address)
    |> from("admin@example.com")
  end

  defp add_body(email, :verify_request, nil) do
    text_body(
      email,
      "Someone tried to use this email address to register an account with Vutuv, but this email address is already in use." <>
        "If you have forgotten your password, go to the Login page and click on the forgot password link to reset your password."
    )
  end

  defp add_body(email, :verify_request, code) do
    text_body(email, "Enter the following verification code:\n#{code}")
  end

  defp add_body(email, :reset_request, nil) do
    text_body(
      email,
      "You requested a password reset, but no user is associated with the email you provided."
    )
  end

  defp add_body(email, :reset_request, code) do
    text_body(email, "Enter the following password reset code:\n#{code}")
  end
end
