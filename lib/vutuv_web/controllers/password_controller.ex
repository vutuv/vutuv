defmodule VutuvWeb.PasswordController do
  use VutuvWeb, :controller

  import VutuvWeb.Authorize

  alias Vutuv.{Accounts, Accounts.UserCredential, Devices, Devices.EmailAddress}
  alias VutuvWeb.Email

  plug VutuvWeb.RateLimiter, [type: :password] when action in [:create]

  def action(conn, _), do: auth_action_slug(conn, __MODULE__)

  def new(conn, _, current_user) do
    %EmailAddress{value: email} = Devices.get_primary_email(current_user)
    user_credential = Accounts.get_user_credential(%{"email" => email})
    changeset = Accounts.change_update_password(user_credential)
    render(conn, "new.html", email: email, changeset: changeset)
  end

  def create(conn, %{"password" => %{"old_password" => old} = params}, current_user) do
    %UserCredential{password_hash: hash} =
      user_credential = Accounts.get_user_credential!(%{"user_id" => current_user.id})

    if hash && Argon2.verify_pass(old, hash) do
      VutuvWeb.RateLimiter.reset_count(conn)
      do_create(conn, current_user, user_credential, params)
    else
      unauthorized(conn, current_user)
    end
  end

  def do_create(conn, user, user_credential, %{"email" => email} = params) do
    case Accounts.update_password(user_credential, params) do
      {:ok, _user_credential} ->
        Email.update_password_complete(email, user.locale)

        conn
        |> clear_session()
        |> configure_session(renew: true)
        |> put_flash(:info, gettext("Your password has been updated."))
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", email: email, changeset: changeset)
    end
  end
end
