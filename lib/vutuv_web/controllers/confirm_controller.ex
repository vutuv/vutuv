defmodule VutuvWeb.ConfirmController do
  use VutuvWeb, :controller

  alias Vutuv.Accounts
  alias VutuvWeb.{Auth.Otp, Email}

  def new(conn, %{"email" => email}) do
    render(conn, "new.html", email: email)
  end

  def create(conn, %{"confirm" => %{"email" => email, "code" => code}}) do
    case Otp.verify(code) do
      {:ok, %{email_addresses: email_addresses} = user} ->
        unless user.confirmed_at, do: Accounts.confirm_user(user)

        email_addresses
        |> Enum.find(&(&1.value == email))
        |> Accounts.confirm_email_address()

        Email.confirm_success(email)

        conn
        |> put_flash(:info, "Your account has been confirmed")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> render("new.html")
    end
  end
end
