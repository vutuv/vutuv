defmodule Vutuv.AddressControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.Address
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, address_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing addresses"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, address_path(conn, :new)
    assert html_response(conn, 200) =~ "New address"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, address_path(conn, :create), address: @valid_attrs
    assert redirected_to(conn) == address_path(conn, :index)
    assert Repo.get_by(Address, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, address_path(conn, :create), address: @invalid_attrs
    assert html_response(conn, 200) =~ "New address"
  end

  test "shows chosen resource", %{conn: conn} do
    address = Repo.insert! %Address{}
    conn = get conn, address_path(conn, :show, address)
    assert html_response(conn, 200) =~ "Show address"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, address_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    address = Repo.insert! %Address{}
    conn = get conn, address_path(conn, :edit, address)
    assert html_response(conn, 200) =~ "Edit address"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    address = Repo.insert! %Address{}
    conn = put conn, address_path(conn, :update, address), address: @valid_attrs
    assert redirected_to(conn) == address_path(conn, :show, address)
    assert Repo.get_by(Address, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    address = Repo.insert! %Address{}
    conn = put conn, address_path(conn, :update, address), address: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit address"
  end

  test "deletes chosen resource", %{conn: conn} do
    address = Repo.insert! %Address{}
    conn = delete conn, address_path(conn, :delete, address)
    assert redirected_to(conn) == address_path(conn, :index)
    refute Repo.get(Address, address.id)
  end
end
