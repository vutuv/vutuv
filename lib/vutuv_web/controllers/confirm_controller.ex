defmodule VutuvWeb.ConfirmController do
  use VutuvWeb, :controller

  alias Phauxth.Confirm
  alias Vutuv.Accounts
  alias VutuvWeb.Email

  def index(conn, params) do
    case Confirm.verify(params) do
      {:ok, user} ->
        Accounts.confirm_user(user)
        Accounts.verify_email(user)

        email_addresses = Accounts.list_email_address_user(user.id)

        for email_address <- email_addresses do
          Email.confirm_success(email_address)
        end

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
