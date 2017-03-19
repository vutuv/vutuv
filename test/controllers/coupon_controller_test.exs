defmodule Vutuv.CouponControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.Coupon
  @valid_attrs %{amount: "120.5", code: "some content", ends_on: %{day: 17, month: 4, year: 2010}, percentage: 42, user_id: 42}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, admin_coupon_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing coupons"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, admin_coupon_path(conn, :new)
    assert html_response(conn, 200) =~ "New coupon"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, admin_coupon_path(conn, :create), coupon: @valid_attrs
    assert redirected_to(conn) == admin_coupon_path(conn, :index)
    assert Repo.get_by(Coupon, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, admin_coupon_path(conn, :create), coupon: @invalid_attrs
    assert html_response(conn, 200) =~ "New coupon"
  end

  test "shows chosen resource", %{conn: conn} do
    coupon = Repo.insert! %Coupon{}
    conn = get conn, admin_coupon_path(conn, :show, coupon)
    assert html_response(conn, 200) =~ "Show coupon"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, admin_coupon_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    coupon = Repo.insert! %Coupon{}
    conn = get conn, admin_coupon_path(conn, :edit, coupon)
    assert html_response(conn, 200) =~ "Edit coupon"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    coupon = Repo.insert! %Coupon{}
    conn = put conn, admin_coupon_path(conn, :update, coupon), coupon: @valid_attrs
    assert redirected_to(conn) == admin_coupon_path(conn, :show, coupon)
    assert Repo.get_by(Coupon, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    coupon = Repo.insert! %Coupon{}
    conn = put conn, admin_coupon_path(conn, :update, coupon), coupon: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit coupon"
  end

  test "deletes chosen resource", %{conn: conn} do
    coupon = Repo.insert! %Coupon{}
    conn = delete conn, admin_coupon_path(conn, :delete, coupon)
    assert redirected_to(conn) == admin_coupon_path(conn, :index)
    refute Repo.get(Coupon, coupon.id)
  end
end
