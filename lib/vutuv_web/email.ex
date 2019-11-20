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
  import VutuvWeb.Gettext

  alias VutuvWeb.Mailer

  @doc """
  Sends a notification email.
  """
  def send_notification(address, subject, body) do
    address
    |> text_email(subject, body)
    |> Mailer.deliver_later()
  end

  @doc """
  An email containing the verification code.
  """
  def verify_request(address, nil, locale) do
    (locale || "en")
    |> Gettext.with_locale(fn ->
      text_email(address, dgettext("mail", "verify email"), dgettext("mail", "email in use"))
    end)
    |> Mailer.deliver_later()
  end

  def verify_request(address, code, locale) do
    (locale || "en")
    |> Gettext.with_locale(fn ->
      text_email(
        address,
        dgettext("mail", "verify email"),
        dgettext("mail", "verification code:\n%{msg}", msg: code)
      )
    end)
    |> Mailer.deliver_later()
  end

  @doc """
  An email containing the verification code needed to reset the password.
  """
  def reset_request(address, nil, locale) do
    (locale || "en")
    |> Gettext.with_locale(fn ->
      text_email(
        address,
        dgettext("mail", "reset password"),
        dgettext("mail", "reset password no user")
      )
    end)
    |> Mailer.deliver_later()
  end

  def reset_request(address, code, locale) do
    (locale || "en")
    |> Gettext.with_locale(fn ->
      text_email(
        address,
        dgettext("mail", "reset password"),
        dgettext("mail", "reset password code:\n%{msg}", msg: code)
      )
    end)
    |> Mailer.deliver_later()
  end

  @doc """
  An email acknowledging that the email has been successfully verified.
  """
  def verify_success(address, locale) do
    (locale || "en")
    |> Gettext.with_locale(fn ->
      text_email(
        address,
        dgettext("mail", "email verified"),
        dgettext("mail", "email verified successfully")
      )
    end)
    |> Mailer.deliver_later()
  end

  @doc """
  An email acknowledging that the password has been successfully reset.
  """
  def reset_success(address, locale) do
    (locale || "en")
    |> Gettext.with_locale(fn ->
      text_email(
        address,
        dgettext("mail", "password reset"),
        dgettext("mail", "password reset successfully")
      )
    end)
    |> Mailer.deliver_later()
  end

  defp base_email(address) do
    new_email()
    |> to(address)
    |> from("admin@example.com")
  end

  defp text_email(address, subject, body) do
    address
    |> base_email()
    |> subject(subject)
    |> text_body(body)
  end
end
