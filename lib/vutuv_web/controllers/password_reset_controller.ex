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

      Accounts.set_password_reset_status(user_credential, %{
        password_reset_sent_at: DateTime.truncate(DateTime.utc_now(), :second),
        password_resettable: true
      })
    end

    conn
    |> put_flash(
      :info,
      gettext("Check your inbox for instructions on how to reset your password")
    )
    |> redirect(to: Routes.password_reset_path(conn, :new, email: email))
  end

  def new(conn, %{"email" => email}) do
    render(conn, "new.html", email: email)
  end

  def create(conn, %{"password_reset" => %{"email" => email, "code" => code}}) do
    user_credential = Accounts.get_user_credential(%{"email" => email})

    if request_sent?(user_credential) && Otp.verify(code, user_credential.otp_secret) do
      Email.verify_success(email)
      Accounts.set_password_reset_status(user_credential, %{password_resettable: true})

      conn
      |> put_session(:password_reset, true)
      |> redirect(to: Routes.password_reset_path(conn, :edit, email: email))
    else
      conn
      |> put_flash(:error, gettext("Invalid code"))
      |> render("new.html", email: email)
    end
  end

  def edit(conn, %{"email" => email}) do
    user_credential = Accounts.get_user_credential(%{"email" => email})

    if get_session(conn, :password_reset) && Accounts.can_reset_password?(user_credential) do
      render(conn, "edit.html", email: email)
    else
      unauthorized(conn)
    end
  end

  def update(conn, %{"password_reset" => %{"email" => email} = params}) do
    user_credential = Accounts.get_user_credential(%{"email" => email})

    case Accounts.can_reset_password?(user_credential) &&
           Accounts.update_password(user_credential, params) do
      {:ok, _user_credential} ->
        Email.reset_success(email)

        Accounts.set_password_reset_status(user_credential, %{
          password_reset_sent_at: nil,
          password_resettable: false
        })

        conn
        |> clear_session()
        |> configure_session(renew: true)
        |> put_flash(:info, gettext("Your password has been reset"))
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, %Ecto.Changeset{} = changeset} ->
        message = with p <- changeset.errors[:password], do: elem(p, 0)

        conn
        |> put_flash(:error, message || gettext("Invalid input"))
        |> render("edit.html", email: email)

      error when error in [nil, false] ->
        unauthorized(conn)
    end
  end

  defp unauthorized(conn) do
    conn
    |> put_flash(:error, gettext("You are not authorized to view this page"))
    |> redirect(to: Routes.session_path(conn, :new))
    |> halt()
  end

  defp request_sent?(user_credential) do
    user_credential && user_credential.password_reset_sent_at
  end
end
