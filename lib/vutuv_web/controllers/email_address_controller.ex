defmodule VutuvWeb.EmailAddressController do
  use VutuvWeb, :controller

  import VutuvWeb.AuthorizeConn

  alias Vutuv.{Accounts, Accounts.EmailAddress}
  alias VutuvWeb.{Auth.Otp, Email}

  @dialyzer {:nowarn_function, new: 3}

  def action(conn, _), do: auth_action_slug(conn, __MODULE__)

  def index(conn, _params, user) do
    email_addresses = Accounts.list_email_addresses(user)
    render(conn, "index.html", email_addresses: email_addresses)
  end

  def new(conn, _params, _user) do
    changeset = Accounts.change_email_address(%EmailAddress{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"email_address" => email_address_params}, user) do
    case Accounts.create_email_address(user, email_address_params) do
      {:ok, email_address} ->
        user_credential = Accounts.get_user_credential!(%{"user_id" => user.id})
        code = Otp.create(user_credential.otp_secret)
        Email.confirm_request(email_address.value, code)

        conn
        |> put_flash(:info, "Email address created successfully.")
        |> redirect(to: Routes.confirm_path(conn, :new, email: email_address.value))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    email_address = Accounts.get_email_address!(user, %{"id" => id})
    render(conn, "show.html", email_address: email_address)
  end

  def edit(conn, %{"id" => id}, user) do
    email_address = Accounts.get_email_address!(user, %{"id" => id})
    changeset = Accounts.change_email_address(email_address)
    render(conn, "edit.html", email_address: email_address, changeset: changeset)
  end

  def update(conn, %{"id" => id, "email_address" => email_address_params}, user) do
    email_address = Accounts.get_email_address!(user, %{"id" => id})

    case Accounts.update_email_address(email_address, email_address_params) do
      {:ok, email_address} ->
        conn
        |> put_flash(:info, "Email address updated successfully.")
        |> redirect(to: Routes.user_email_address_path(conn, :show, user, email_address))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", email_address: email_address, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    email_address = Accounts.get_email_address!(user, %{"id" => id})
    {:ok, _email_address} = Accounts.delete_email_address(email_address)

    conn
    |> put_flash(:info, "Email address deleted successfully.")
    |> redirect(to: Routes.user_email_address_path(conn, :index, user))
  end
end
