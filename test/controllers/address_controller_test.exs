defmodule Vutuv.AddressControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.Address
  @valid_attrs %{}
  @invalid_attrs %{}

  # test "lists all entries on index", %{conn: conn} do
  #   conn = get conn, user_address_path(conn, :index, conn.assigns[:user])
  #   assert html_response(conn, 200) =~ "Listing addresses"
  # end

  # test "renders form for new resources", %{conn: conn} do
  #   conn = get conn, user_address_path(conn, :new, conn.assigns[:user])
  #   assert html_response(conn, 200) =~ "New address"
  # end

  # test "creates resource and redirects when data is valid", %{conn: conn} do
  #   conn = post conn, user_address_path(conn, :create, conn.assigns[:user]), address: @valid_attrs
  #   assert redirected_to(conn) == user_address_path(conn, :index, conn.assigns[:user])
  #   assert Repo.get_by(Address, @valid_attrs)
  # end

  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, user_address_path(conn, :create, conn.assigns[:user]), address: @invalid_attrs
  #   assert html_response(conn, 200) =~ "New address"
  # end

  # test "shows chosen resource", %{conn: conn} do
  #   address = Repo.insert! %Address{}
  #   conn = get conn, user_address_path(conn, :show, conn.assigns[:user], address)
  #   assert html_response(conn, 200) =~ "Show address"
  # end

  # test "renders page not found when id is nonexistent", %{conn: conn} do
  #   assert_error_sent 404, fn ->
  #     get conn, user_address_path(conn, :show, conn.assigns[:user], -1)
  #   end
  # end

  # test "renders form for editing chosen resource", %{conn: conn} do
  #   address = Repo.insert! %Address{}
  #   conn = get conn, user_address_path(conn, :edit, conn.assigns[:user], address)
  #   assert html_response(conn, 200) =~ "Edit address"
  # end

  # test "updates chosen resource and redirects when data is valid", %{conn: conn} do
  #   address = Repo.insert! %Address{}
  #   conn = put conn, user_address_path(conn, :update, conn.assigns[:user], address), address: @valid_attrs
  #   assert redirected_to(conn) == user_address_path(conn, :show, conn.assigns[:user], address)
  #   assert Repo.get_by(Address, @valid_attrs)
  # end

  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   address = Repo.insert! %Address{}
  #   conn = put conn, user_address_path(conn, :update, conn.assigns[:user], address), address: @invalid_attrs
  #   assert html_response(conn, 200) =~ "Edit address"
  # end

  # test "deletes chosen resource", %{conn: conn} do
  #   address = Repo.insert! %Address{}
  #   conn = delete conn, user_address_path(conn, :delete, conn.assigns[:user], address)
  #   assert redirected_to(conn) == user_address_path(conn, conn.assigns[:user], :index)
  #   refute Repo.get(Address, address.id)
  # end
end
