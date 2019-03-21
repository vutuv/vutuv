defmodule VutuvWeb.Email do
  @moduledoc """
  A module for sending emails to the user.

  This module provides functions to be used with the Phauxth authentication
  library when confirming users or handling password resets. It uses
  Bamboo, with the LocalAdapter, which is a good development tool.
  For tests, it uses a test adapter, which is configured in the
  config/test.exs file.

  For production, you will need to setup a different email adapter.

  ## Bamboo with a different adapter

  Bamboo has adapters for Mailgun, Mailjet, Mandrill, Sendgrid, SMTP,
  SparkPost, PostageApp, Postmark and Sendcloud.

  There is also a LocalAdapter, which is great for local development.

  See [Bamboo](https://github.com/thoughtbot/bamboo) for more information.

  ## Other email library

  If you do not want to use Bamboo, follow the instructions below:

  1. Edit this file, using the email library of your choice
  2. Remove the lib/vutuv/mailer.ex file
  3. Remove the Bamboo entries in the config/config.exs and config/test.exs files
  4. Remove bamboo from the deps section in the mix.exs file

  """

  import Bamboo.Email
  alias VutuvWeb.Mailer

  @doc """
  An email with a confirmation link in it.
  """
  def confirm_request(address, key) do
    prep_mail(address)
    |> subject("Confirm your account")
    |> text_body("Confirm your email here #{Application.get_env(:vutuv, :email_url)}=#{key}")
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

  def reset_request(address, key) do
    prep_mail(address)
    |> subject("Reset your password")
    |> text_body("Reset your password at http://www.example.com/password_resets/edit?key=#{key}")
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

  def verify_email_request(address, key) do
    prep_mail(address)
    |> subject("Verify your email")
    |> text_body("Verify your email here #{Application.get_env(:vutuv, :email_url)}=#{key}")
    |> Mailer.deliver_now()
  end

  defp prep_mail(address) do
    new_email()
    |> to(address)
    |> from("admin@example.com")
  end
end
