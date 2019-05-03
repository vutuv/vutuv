defmodule VutuvWeb.ConfirmController do
  use VutuvWeb, :controller

  alias Vutuv.Accounts
  alias VutuvWeb.{Auth.Confirm, Email}

  def index(conn, params) do
    case Confirm.verify(params) do
      {:ok, %{current_email: email, email_addresses: email_addresses} = user} ->
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
        |> redirect(to: Routes.session_path(conn, :new))
    end
  end
end
