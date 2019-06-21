defmodule VutuvWeb.PasswordResetController do
  use VutuvWeb, :controller

  alias Vutuv.Accounts
  alias VutuvWeb.{Auth.Otp, Email}

  def new_request(conn, _params) do
    render(conn, "new_request.html")
  end

  def create_request(conn, %{"password_reset" => %{"email" => email}}) do
    code = if Accounts.get_email_address_from_value(email), do: Otp.create()
    Email.reset_request(email, code)

    conn
    |> put_flash(:info, "Check your inbox for instructions on how to reset your password")
    |> redirect(to: Routes.password_reset_path(conn, :new, email: email))
  end

  def new(conn, %{"email" => email}) do
    render(conn, "new.html", email: email)
  end

  def create(conn, %{"password_reset" => %{"email" => email, "code" => code}}) do
    email_address = Accounts.get_email_address_from_value(email)

    if email_address && Otp.verify(code) do
      user = Accounts.get_user(email_address.user_id)
      Email.confirm_success(email)
      redirect(conn, to: Routes.password_reset_path(conn, :edit, user, email: email))
    else
      conn
      |> put_flash(:error, "Invalid code")
      |> render("new.html", email: email)
    end
  end

  def edit(conn, %{"id" => user_id, "email" => email}) do
    user = Accounts.get_user(user_id)
    render(conn, "edit.html", user: user, email: email)
  end

  def update(conn, %{"id" => user_id, "password_reset" => %{"email" => email} = params}) do
    user = Accounts.get_user(user_id)

    case Accounts.update_password(user, params) do
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
        |> render("edit.html", user: user, email: email)
    end
  end
end
