defmodule VutuvWeb.ConfirmController do
  use VutuvWeb, :controller

  alias Vutuv.Accounts
  alias VutuvWeb.{Auth.Otp, Email}

  def new(conn, %{"email" => email}) do
    user_credential = Accounts.get_user_credential(%{"email" => email})
    code = Otp.create(user_credential.otp_secret)
    Email.confirm_request(email, code)
    render(conn, "new.html", email: email)
  end

  def create(conn, %{"confirm" => %{"email" => email, "code" => code}}) do
    user_credential = Accounts.get_user_credential(%{"email" => email})

    if Otp.verify(code, user_credential.otp_secret) do
      email_address = Accounts.get_email_address(%{"value" => email})
      unless user_credential.confirmed, do: Accounts.confirm_user(user_credential)
      Accounts.confirm_email_address(email_address)
      Email.confirm_success(email)

      conn
      |> put_flash(:info, "Your account has been confirmed")
      |> redirect(to: Routes.session_path(conn, :new))
    else
      conn
      |> put_flash(:error, "Invalid code")
      |> render("new.html", email: email)
    end
  end
end
