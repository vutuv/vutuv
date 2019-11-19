defmodule VutuvWeb.Api.AddressController do
  use VutuvWeb, :controller

  import VutuvWeb.Api.Authorize

  alias Vutuv.UserProfiles
  alias Vutuv.UserProfiles.{Address, User}

  action_fallback VutuvWeb.Api.FallbackController

  def action(conn, _), do: auth_action_slug(conn, __MODULE__, [:index, :show])

  def index(conn, %{"user_slug" => slug}, %User{slug: slug} = current_user) do
    addresses = UserProfiles.list_addresses(current_user)
    render(conn, "index.json", addresses: addresses, user: current_user)
  end

  def index(conn, %{"user_slug" => slug}, _current_user) do
    user = UserProfiles.get_user!(%{"slug" => slug})
    addresses = UserProfiles.list_addresses(user)
    render(conn, "index.json", addresses: addresses, user: user)
  end

  def create(conn, %{"address" => address_params}, current_user) do
    with {:ok, %Address{} = address} <- UserProfiles.create_address(current_user, address_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        Routes.api_user_address_path(conn, :show, current_user, address)
      )
      |> render("show.json", address: address, user: current_user)
    end
  end

  def show(conn, %{"id" => id, "user_slug" => slug}, %User{slug: slug} = current_user) do
    address = UserProfiles.get_address!(current_user, id)
    render(conn, "show.json", address: address, user: current_user)
  end

  def show(conn, %{"id" => id, "user_slug" => slug}, _current_user) do
    user = UserProfiles.get_user!(%{"slug" => slug})
    address = UserProfiles.get_address!(user, id)
    render(conn, "show.json", address: address, user: user)
  end

  def update(conn, %{"id" => id, "address" => address_params}, current_user) do
    address = UserProfiles.get_address!(current_user, id)

    with {:ok, %Address{} = address} <- UserProfiles.update_address(address, address_params) do
      render(conn, "show.json", address: address, user: current_user)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    address = UserProfiles.get_address!(current_user, id)

    with {:ok, %Address{}} <- UserProfiles.delete_address(address) do
      send_resp(conn, :no_content, "")
    end
  end
end
