defmodule VutuvWeb.Api.EmailAddressController do
  use VutuvWeb, :controller

  import VutuvWeb.Api.Authorize

  alias Vutuv.{Devices, Devices.EmailAddress}

  action_fallback VutuvWeb.Api.FallbackController

  def action(conn, _), do: auth_action_slug(conn, __MODULE__)

  def index(conn, _params, current_user) do
    email_addresses = Devices.list_email_addresses(current_user)
    render(conn, "index.json", email_addresses: email_addresses, user: current_user)
  end

  def create(conn, %{"email_address" => email_address_params}, current_user) do
    with {:ok, %EmailAddress{} = email_address} <-
           Devices.create_email_address(current_user, email_address_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        Routes.user_email_address_path(conn, :show, current_user, email_address)
      )
      |> render("show.json", email_address: email_address, user: current_user)
    end
  end

  def show(conn, %{"id" => id}, current_user) do
    email_address = Devices.get_email_address!(current_user, id)
    render(conn, "show.json", email_address: email_address, user: current_user)
  end

  def set_primary(conn, %{"id" => id}, current_user) do
    email_address = Devices.get_email_address!(current_user, id)

    with {:ok, %EmailAddress{} = email_address} <- Devices.set_primary_email(email_address) do
      render(conn, "show.json", email_address: email_address, user: current_user)
    end
  end

  def update(conn, %{"id" => id, "email_address" => email_address_params}, current_user) do
    email_address = Devices.get_email_address!(current_user, id)

    with {:ok, %EmailAddress{} = email_address} <-
           Devices.update_email_address(email_address, email_address_params) do
      render(conn, "show.json", email_address: email_address, user: current_user)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    email_address = Devices.get_email_address!(current_user, id)

    with {:ok, %EmailAddress{}} <- Devices.delete_email_address(email_address) do
      send_resp(conn, :no_content, "")
    end
  end
end
