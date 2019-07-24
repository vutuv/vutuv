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
  An email with a confirmation link in it.
  """
  def confirm_request(address, code) do
    prep_mail(address)
    |> subject("Confirm your account")
    |> text_body("Enter the following confirmation code:\n#{code}")
    |> Mailer.deliver_now()
  end

  @doc """
  An email with a link to reset the password.
  """
  def reset_request(address, nil) do
    prep_mail(address)
    |> subject("Reset your password")
    |> text_body(
      "You requested a password reset, but no user is associated with the email you provided."
    )
    |> Mailer.deliver_now()
  end

  def reset_request(address, code) do
    prep_mail(address)
    |> subject("Reset your password")
    |> text_body("Enter the following password reset code:\n#{code}")
    |> Mailer.deliver_now()
  end

  @doc """
  An email acknowledging that the account has been successfully confirmed.
  """
  def confirm_success(address) do
    prep_mail(address)
    |> subject("Confirmed account")
    |> text_body("Your account has been confirmed.")
    |> Mailer.deliver_now()
  end

  @doc """
  An email acknowledging that the password has been successfully reset.
  """
  def reset_success(address) do
    prep_mail(address)
    |> subject("Password reset")
    |> text_body("Your password has been reset.")
    |> Mailer.deliver_now()
  end

  defp prep_mail(address) do
    new_email()
    |> to(address)
    |> from("admin@example.com")
  end
end
