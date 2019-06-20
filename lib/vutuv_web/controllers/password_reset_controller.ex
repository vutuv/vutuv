defmodule VutuvWeb.PasswordResetController do
  use VutuvWeb, :controller

  alias Vutuv.Accounts
  alias VutuvWeb.{Auth.Otp, Email}

  def new_request(conn, _params) do
    render(conn, "new_request.html")
  end

  def create_request(conn, %{"password_reset" => %{"email" => email}}) do
    # register that a password reset reqest was sent
    Accounts.create_password_reset(%{"email" => email})
    code = Otp.create()
    Email.reset_request(email, code)

    conn
    |> put_flash(:info, "Check your inbox for instructions on how to reset your password")
    |> redirect(to: Routes.password_reset_path(conn, :new, email: email))
  end

  def new(conn, %{"email" => email}) do
    render(conn, "new.html", email: email)
  end

  def create(conn, %{"password_reset" => %{"email" => email, "code" => code}}) do
    case Otp.verify(code) do
      {:ok, %{email_addresses: email_addresses} = user} ->
        unless user.confirmed_at, do: Accounts.confirm_user(user)

        email_addresses
        |> Enum.find(&(&1.value == email))
        |> Accounts.confirm_email_address()

        Email.confirm_success(email)

        conn
        # change this message
        |> put_flash(:info, "Your account has been confirmed")
        # if using id, add user before email
        |> redirect(to: Routes.password_reset_path(conn, :edit, email: email))

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> render("new.html")
    end
  end

  def edit(conn, %{"email" => email}) do
    render(conn, "edit.html", email: email)
  end

  def update(conn, %{"password_reset" => %{"email" => email} = params}) do
    user = Accounts.get_user(email.user_id)

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
        |> render("edit.html", email: email)
    end
  end
end
