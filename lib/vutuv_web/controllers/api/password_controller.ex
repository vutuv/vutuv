defmodule VutuvWeb.Api.PasswordController do
  use VutuvWeb, :controller

  import VutuvWeb.Api.Authorize

  alias Vutuv.{Accounts, Accounts.UserCredential}
  alias VutuvWeb.Email

  plug VutuvWeb.RateLimiter, [type: :password] when action in [:create]

  def action(conn, _), do: auth_action_slug(conn, __MODULE__)

  def create(conn, %{"password" => %{"old_password" => old} = params}, current_user) do
    %UserCredential{password_hash: hash} =
      user_credential = Accounts.get_user_credential!(%{"user_id" => current_user.id})

    if hash && Argon2.verify_pass(old, hash) do
      VutuvWeb.RateLimiter.reset_count(conn)
      do_create(conn, current_user, user_credential, params)
    else
      conn
      |> put_status(:unauthorized)
      |> render("error.json", error: gettext("Current password is incorrect."))

      # render(conn, "error.json", error: gettext("Current password is incorrect."))
    end
  end

  def do_create(conn, user, user_credential, %{"email" => email} = params) do
    case Accounts.update_password(user_credential, params) do
      {:ok, _user_credential} ->
        Email.update_password_complete(email, user.locale)
        render(conn, "info.json", info: gettext("Your password has been updated."))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(VutuvWeb.Api.ChangesetView)
        |> render("error.json", changeset: changeset)
    end
  end
end
