defmodule Vutuv.MembershipControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.Membership
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, membership_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing memberships"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, membership_path(conn, :new)
    assert html_response(conn, 200) =~ "New membership"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, membership_path(conn, :create), membership: @valid_attrs
    assert redirected_to(conn) == membership_path(conn, :index)
    assert Repo.get_by(Membership, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, membership_path(conn, :create), membership: @invalid_attrs
    assert html_response(conn, 200) =~ "New membership"
  end

  test "shows chosen resource", %{conn: conn} do
    membership = Repo.insert! %Membership{}
    conn = get conn, membership_path(conn, :show, membership)
    assert html_response(conn, 200) =~ "Show membership"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, membership_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    membership = Repo.insert! %Membership{}
    conn = get conn, membership_path(conn, :edit, membership)
    assert html_response(conn, 200) =~ "Edit membership"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    membership = Repo.insert! %Membership{}
    conn = put conn, membership_path(conn, :update, membership), membership: @valid_attrs
    assert redirected_to(conn) == membership_path(conn, :show, membership)
    assert Repo.get_by(Membership, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    membership = Repo.insert! %Membership{}
    conn = put conn, membership_path(conn, :update, membership), membership: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit membership"
  end

  test "deletes chosen resource", %{conn: conn} do
    membership = Repo.insert! %Membership{}
    conn = delete conn, membership_path(conn, :delete, membership)
    assert redirected_to(conn) == membership_path(conn, :index)
    refute Repo.get(Membership, membership.id)
  end
end
