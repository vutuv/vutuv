defmodule VutuvWeb.Api.EmailAddressController do
  use VutuvWeb, :controller

  import VutuvWeb.Api.Authorize

  alias Vutuv.Accounts
  alias Vutuv.Accounts.EmailAddress

  action_fallback VutuvWeb.Api.FallbackController

  def action(conn, _), do: auth_action_id(conn, __MODULE__)

  def index(conn, _params, user) do
    email_addresses = Accounts.list_email_addresses(user)
    render(conn, "index.json", email_addresses: email_addresses)
  end

  def create(conn, %{"email_address" => email_address_params}, user) do
    with {:ok, %EmailAddress{} = email_address} <-
           Accounts.create_email_address(user, email_address_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        Routes.user_email_address_path(conn, :show, user.id, email_address)
      )
      |> render("show.json", email_address: email_address)
    end
  end

  def show(conn, %{"id" => id}, user) do
    case Accounts.get_user_email_address(user, id) do
      %EmailAddress{} = email_address -> render(conn, "show.json", email_address: email_address)
      _ -> error(conn, :forbidden, 403)
    end
  end

  def update(conn, %{"id" => id, "email_address" => email_address_params}, user) do
    if email_address = Accounts.get_user_email_address(user, id) do
      do_update(conn, email_address, email_address_params)
    else
      error(conn, :forbidden, 403)
    end
  end

  defp do_update(conn, email_address, email_address_params) do
    with {:ok, %EmailAddress{} = email_address} <-
           Accounts.update_email_address(email_address, email_address_params) do
      render(conn, "show.json", email_address: email_address)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    if email_address = Accounts.get_user_email_address(user, id) do
      do_delete(conn, email_address)
    else
      error(conn, :forbidden, 403)
    end
  end

  defp do_delete(conn, email_address) do
    with {:ok, %EmailAddress{}} <- Accounts.delete_email_address(email_address) do
      send_resp(conn, :no_content, "")
    end
  end
end
