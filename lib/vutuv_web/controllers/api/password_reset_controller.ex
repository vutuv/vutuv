defmodule VutuvWeb.Api.PasswordResetController do
  use VutuvWeb, :controller

  import VutuvWeb.Api.Authorize

  alias Vutuv.{Accounts, UserProfiles}
  alias VutuvWeb.{Auth.Otp, Auth.Token, Email}

  plug :check_key when action in [:update]

  def create_request(conn, %{"password_reset" => %{"email" => email}}) do
    if user_credential = Accounts.get_user_credential(%{"email" => email}) do
      code = Otp.create(user_credential.otp_secret)
      user = UserProfiles.get_user(user_credential.user_id)
      Email.reset_request(email, code, user.locale)

      Accounts.set_password_reset_status(user_credential, %{
        password_reset_sent_at: DateTime.truncate(DateTime.utc_now(), :second),
        password_resettable: true
      })
    end

    conn
    |> put_status(:created)
    |> render("info.json",
      info: gettext("Check your inbox for instructions on how to reset your password.")
    )
  end

  def create(conn, %{"password_reset" => %{"email" => email, "code" => code}}) do
    user_credential = Accounts.get_user_credential(%{"email" => email})

    if request_sent?(user_credential) && Otp.verify(code, user_credential.otp_secret) do
      key = Token.sign(%{"email" => email})
      user = UserProfiles.get_user(user_credential.user_id)
      Email.verify_success(email, user.locale)
      Accounts.set_password_reset_status(user_credential, %{password_resettable: true})

      conn
      |> put_status(:created)
      |> render("info.json", info: gettext("Code input correctly"), key: key)
    else
      conn
      |> put_status(:unauthorized)
      |> render("error.json", error: gettext("Invalid code"))
    end
  end

  def update(conn, %{"password_reset" => %{"email" => email} = params}) do
    user_credential = Accounts.get_user_credential(%{"email" => email})

    case Accounts.can_reset_password?(user_credential) &&
           Accounts.update_password(user_credential, params) do
      {:ok, _user_credential} ->
        user = UserProfiles.get_user(user_credential.user_id)
        Email.reset_success(email, user.locale)

        Accounts.set_password_reset_status(user_credential, %{
          password_reset_sent_at: nil,
          password_resettable: false
        })

        conn
        |> render("info.json", info: gettext("Your password has been reset"))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(VutuvWeb.Api.ChangesetView)
        |> render("error.json", changeset: changeset)

      error when error in [nil, false] ->
        error(conn, :unauthorized, 401)
    end
  end

  defp request_sent?(user_credential) do
    user_credential && user_credential.password_reset_sent_at
  end

  defp check_key(
         %Plug.Conn{params: %{"password_reset" => %{"email" => email, "key" => key}}} = conn,
         _
       ) do
    case Token.verify(key, max_age: 600) do
      {:ok, %{"email" => ^email}} -> conn
      _ -> error(conn, :unauthorized, 401)
    end
  end

  defp check_key(conn, _) do
    error(conn, :unauthorized, 401)
  end
end
