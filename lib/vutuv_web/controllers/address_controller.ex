defmodule VutuvWeb.AddressController do
  use VutuvWeb, :controller

  import VutuvWeb.Authorize

  alias Vutuv.Accounts
  alias Vutuv.Accounts.{Address, User}

  @dialyzer {:nowarn_function, new: 3}

  def action(conn, _) do
    if action_name(conn) in [:index, :show] do
      apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
    else
      auth_action_slug(conn, __MODULE__)
    end
  end

  def index(conn, %{"user_slug" => slug}, %User{slug: slug} = current_user) do
    addresses = Accounts.list_addresses(current_user)
    render(conn, "index.html", addresses: addresses, user: current_user)
  end

  def index(conn, %{"user_slug" => slug}, _current_user) do
    user = Accounts.get_user!(%{"slug" => slug})
    addresses = Accounts.list_addresses(user)
    render(conn, "index.html", addresses: addresses, user: user)
  end

  def new(conn, _params, _current_user) do
    changeset = Accounts.change_address(%Address{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"address" => address_params}, current_user) do
    case Accounts.create_address(current_user, address_params) do
      {:ok, address} ->
        conn
        |> put_flash(:info, gettext("Address created successfully."))
        |> redirect(to: Routes.user_address_path(conn, :show, current_user, address))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id, "user_slug" => slug}, %User{slug: slug} = current_user) do
    address = Accounts.get_address!(current_user, id)
    render(conn, "show.html", address: address, user: current_user)
  end

  def show(conn, %{"id" => id, "user_slug" => slug}, _current_user) do
    user = Accounts.get_user!(%{"slug" => slug})
    address = Accounts.get_address!(user, id)
    render(conn, "show.html", address: address, user: user)
  end

  def edit(conn, %{"id" => id}, current_user) do
    address = Accounts.get_address!(current_user, id)
    changeset = Accounts.change_address(address)
    render(conn, "edit.html", address: address, changeset: changeset)
  end

  def update(conn, %{"id" => id, "address" => address_params}, current_user) do
    address = Accounts.get_address!(current_user, id)

    case Accounts.update_address(address, address_params) do
      {:ok, address} ->
        conn
        |> put_flash(:info, gettext("Address updated successfully."))
        |> redirect(to: Routes.user_address_path(conn, :show, current_user, address))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", address: address, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    address = Accounts.get_address!(current_user, id)
    {:ok, _address} = Accounts.delete_address(address)

    conn
    |> put_flash(:info, gettext("Address deleted successfully."))
    |> redirect(to: Routes.user_address_path(conn, :index, current_user))
  end
end
