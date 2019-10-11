defmodule VutuvWeb.VerificationController do
  use VutuvWeb, :controller

  alias Vutuv.{Accounts, Devices}
  alias VutuvWeb.{Auth.Otp, Email}

  def new(conn, %{"email" => email}) do
    Devices.get_unverified_email_address!(%{"value" => email})
    render(conn, "new.html", email: email)
  end

  def create(conn, %{"verify" => %{"email" => email, "code" => code}}) do
    user_credential = Accounts.get_user_credential(%{"email" => email})

    if Otp.verify(code, user_credential.otp_secret) do
      email_address = Devices.get_email_address(%{"value" => email})
      unless user_credential.confirmed, do: Accounts.confirm_user(user_credential)
      Devices.verify_email_address(email_address)
      Email.verify_success(email)

      conn
      |> put_flash(:info, gettext("Your email has been verified."))
      |> redirect(to: Routes.session_path(conn, :new))
    else
      conn
      |> put_flash(:error, gettext("Invalid code"))
      |> render("new.html", email: email)
    end
  end

  def send_code(conn, %{"email" => email}) do
    user_credential = Accounts.get_user_credential(%{"email" => email})
    code = Otp.create(user_credential.otp_secret)
    Email.verify_request(email, code)

    conn
    |> put_flash(
      :info,
      gettext("A code has been sent to your email address. Enter that code here.")
    )
    |> redirect(to: Routes.verification_path(conn, :new, email: email))
  end
end
