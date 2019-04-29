defmodule VutuvWeb.ConfirmController do
  use VutuvWeb, :controller

  alias Vutuv.Accounts
  alias VutuvWeb.{Auth.Confirm, Email}

  def index(conn, params) do
    case Confirm.verify(params) do
      {:ok, %{current_email: email} = user} ->
        Accounts.confirm_user_email(user)
        Email.confirm_success(email)

        conn
        |> put_flash(:info, "Your account has been confirmed")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: Routes.session_path(conn, :new))
    end
  end
end
