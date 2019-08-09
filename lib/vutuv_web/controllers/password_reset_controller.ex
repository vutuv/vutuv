defmodule VutuvWeb.PasswordResetController do
  use VutuvWeb, :controller

  alias Vutuv.Accounts
  alias VutuvWeb.{Auth.Otp, Email}

  def new_request(conn, _params) do
    render(conn, "new_request.html")
  end

  def create_request(conn, %{"password_reset" => %{"email" => email}}) do
    if user_credential = Accounts.get_user_credential(%{"email" => email}) do
      code = Otp.create(user_credential.otp_secret)
      Email.reset_request(email, code)
    end

    conn
    |> put_flash(:info, "Check your inbox for instructions on how to reset your password")
    |> redirect(to: Routes.password_reset_path(conn, :new, email: email))
  end

  def new(conn, %{"email" => email}) do
    render(conn, "new.html", email: email)
  end

  def create(conn, %{"password_reset" => %{"email" => email, "code" => code}}) do
    user_credential = Accounts.get_user_credential(%{"email" => email})

    if Otp.verify(code, user_credential.otp_secret) do
      Email.verify_success(email)
      redirect(conn, to: Routes.password_reset_path(conn, :edit, email: email))
    else
      conn
      |> put_flash(:error, "Invalid code")
      |> render("new.html", email: email)
    end
  end

  def edit(conn, %{"email" => email}) do
    render(conn, "edit.html", email: email)
  end

  def update(conn, %{"password_reset" => %{"email" => email} = params}) do
    user_credential = Accounts.get_user_credential(%{"email" => email})

    case Accounts.update_password(user_credential, params) do
      {:ok, _user} ->
        Email.reset_success(email)

        conn
        |> delete_session(:phauxth_session_id)
        |> put_flash(:info, "Your password has been reset")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, %Ecto.Changeset{} = changeset} ->
        message = with p <- changeset.errors[:password], do: elem(p, 0)

        conn
        |> put_flash(:error, message || "Invalid input")
        |> render("edit.html", email: email)
    end
  end
end
