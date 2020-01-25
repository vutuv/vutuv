defmodule VutuvWeb.Api.VerificationController do
  use VutuvWeb, :controller

  alias Vutuv.{Accounts, Devices, UserProfiles}
  alias VutuvWeb.{Auth.Otp, Email}

  plug VutuvWeb.RateLimiter, [type: :verify] when action in [:create]

  def create(conn, %{"verify" => %{"email" => email, "code" => code}}) do
    user_credential = Accounts.get_user_credential(%{"email" => email})

    if Otp.verify(code, user_credential.otp_secret) do
      VutuvWeb.RateLimiter.reset_count(conn)
      email_address = Devices.get_email_address(%{"value" => email})
      unless user_credential.confirmed, do: Accounts.confirm_user(user_credential)
      Devices.verify_email_address(email_address)
      user = UserProfiles.get_user(user_credential.user_id)
      Email.verify_success(email, user.locale)

      conn
      |> put_status(:created)
      |> render("info.json", info: gettext("Your email has been verified"))
    else
      conn
      |> put_status(:unauthorized)
      |> render("error.json", error: gettext("Invalid code"))
    end
  end

  def send_code(conn, %{"email" => email}) do
    user_credential = Accounts.get_user_credential(%{"email" => email})
    code = Otp.create(user_credential.otp_secret)
    user = UserProfiles.get_user(user_credential.user_id)
    Email.verify_request(email, code, user.locale)

    conn
    |> render("info.json",
      info: gettext("A code has been sent to your email address. Enter that code here.")
    )
  end
end
