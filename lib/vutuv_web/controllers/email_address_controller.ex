defmodule VutuvWeb.EmailAddressController do
  use VutuvWeb, :controller

  import VutuvWeb.Authorize

  alias Vutuv.{Accounts, Devices, Devices.EmailAddress, UserProfiles}
  alias VutuvWeb.{Auth.Otp, Email}

  @dialyzer {:nowarn_function, new: 3}

  def action(conn, _), do: auth_action_slug(conn, __MODULE__)

  def index(conn, _params, current_user) do
    email_addresses = Devices.list_email_addresses(current_user)
    render(conn, "index.html", email_addresses: email_addresses)
  end

  def new(conn, _params, _current_user) do
    changeset = Devices.change_email_address(%EmailAddress{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"email_address" => email_address_params}, current_user) do
    case Devices.create_email_address(current_user, email_address_params) do
      {:ok, email_address} ->
        verify_email(conn, %{"email" => email_address.value}, "verify this email address", true)

      {:error, %Ecto.Changeset{} = changeset} ->
        if Devices.duplicate_email_error?(changeset) do
          verify_email(
            conn,
            %{"email" => email_address_params["value"]},
            "verify this email address",
            false
          )
        else
          render(conn, "new.html", changeset: changeset)
        end
    end
  end

  def verify_email(conn, %{"email" => email}, msg, unique_email) do
    user_credential = Accounts.get_user_credential(%{"email" => email})
    code = if unique_email, do: Otp.create(user_credential.otp_secret)
    user = UserProfiles.get_user(user_credential.user_id)
    Email.verify_request(email, code, user.locale)

    conn
    |> put_flash(
      :info,
      gettext("We have sent you an email. Please follow the instructions to %{msg}.", msg: msg)
    )
    |> redirect(to: Routes.verification_path(conn, :new, email: email))
  end

  def show(conn, %{"id" => id}, current_user) do
    email_address = Devices.get_email_address!(current_user, id)
    render(conn, "show.html", email_address: email_address)
  end

  def edit(conn, %{"id" => id}, current_user) do
    email_address = Devices.get_email_address!(current_user, id)
    changeset = Devices.change_email_address(email_address)
    render(conn, "edit.html", email_address: email_address, changeset: changeset)
  end

  def update(conn, %{"id" => id, "email_address" => email_address_params}, current_user) do
    email_address = Devices.get_email_address!(current_user, id)

    case Devices.update_email_address(email_address, email_address_params) do
      {:ok, email_address} ->
        conn
        |> put_flash(:info, gettext("Email address updated successfully."))
        |> redirect(to: Routes.user_email_address_path(conn, :show, current_user, email_address))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", email_address: email_address, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    email_address = Devices.get_email_address!(current_user, id)
    {:ok, _email_address} = Devices.delete_email_address(email_address)

    conn
    |> put_flash(:info, gettext("Email address deleted successfully."))
    |> redirect(to: Routes.user_email_address_path(conn, :index, current_user))
  end
end
