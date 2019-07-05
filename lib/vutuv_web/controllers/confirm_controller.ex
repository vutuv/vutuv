defmodule VutuvWeb.ConfirmController do
  use VutuvWeb, :controller

  alias Vutuv.Accounts
  alias VutuvWeb.{Auth.Otp, Email}

  def new(conn, %{"email" => email}) do
    render(conn, "new.html", email: email)
  end

  def create(conn, %{"confirm" => %{"email" => email, "code" => code}}) do
    user = Accounts.get_by(%{"email" => email})

    if Otp.verify(code, user.otp_secret) do
      email_address = Accounts.get_email_address_from_value(email)
      unless user.confirmed, do: Accounts.confirm_user(user)
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
