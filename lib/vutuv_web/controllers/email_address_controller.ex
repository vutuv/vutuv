defmodule VutuvWeb.EmailAddressController do
  use VutuvWeb, :controller

  alias Vutuv.{Accounts, Accounts.EmailAddress}

  def index(conn, _params) do
    user = conn.assigns.current_user

    email_addresses = Accounts.list_email_addresses(user)
    render(conn, "index.html", email_addresses: email_addresses)
  end

  def new(conn, _params) do
    changeset = Accounts.change_email_address(%EmailAddress{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"email_address" => email_address_params}) do
    user = conn.assigns.current_user

    case Accounts.create_email_address(user, email_address_params) do
      {:ok, email_address} ->
        conn
        |> put_flash(:info, "Email address created successfully.")
        |> redirect(to: Routes.email_address_path(conn, :show, email_address))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    email_address = Accounts.get_email_address(id)
    render(conn, "show.html", email_address: email_address)
  end

  def edit(conn, %{"id" => id}) do
    email_address = Accounts.get_email_address(id)
    changeset = Accounts.change_email_address(email_address)
    render(conn, "edit.html", email_address: email_address, changeset: changeset)
  end

  def update(conn, %{"id" => id, "email_address" => email_address_params}) do
    email_address = Accounts.get_email_address(id)

    case Accounts.update_email_address(email_address, email_address_params) do
      {:ok, email_address} ->
        conn
        |> put_flash(:info, "Email address updated successfully.")
        |> redirect(to: Routes.email_address_path(conn, :show, email_address))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", email_address: email_address, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    email_address = Accounts.get_email_address(id)
    {:ok, _email_address} = Accounts.delete_email_address(email_address)

    conn
    |> put_flash(:info, "Email address deleted successfully.")
    |> redirect(to: Routes.email_address_path(conn, :index))
  end
end
