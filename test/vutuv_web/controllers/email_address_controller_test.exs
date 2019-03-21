defmodule VutuvWeb.EmailAddressControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.Accounts

  @create_attrs %{
    is_public: true,
    description: "some description",
    position: 42,
    user_id: 42,
    value: "abcde@vutuv.de",
    verified: true
  }
  @update_attrs %{
    is_public: false,
    description: "some updated description",
    position: 43,
    user_id: 43,
    value: "abcde@gmail.com",
    verified: false
  }
  @invalid_attrs %{
    is_public: nil,
    description: nil,
    position: nil,
    user_id: nil,
    value: nil,
    verified: nil
  }

  def fixture(:email_address) do
    {:ok, email_address} = Accounts.create_email_address(@create_attrs)
    email_address
  end

  describe "index" do
    test "lists all email_addresses", %{conn: conn} do
      conn = get(conn, Routes.email_address_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Email addresses"
    end
  end

  @tag :skip
  describe "new email_address" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.email_address_path(@conn, :new))
      assert html_response(conn, 200) =~ "New Email address"
    end
  end

  @tag :skip
  describe "create email_address" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.email_address_path(conn, :create), email_address: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.email_address_path(conn, :show, id)

      conn = get(conn, Routes.email_address_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Email address"
    end

    @tag :skip
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.email_address_path(conn, :create), email_address: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Email address"
    end
  end

  describe "edit email_address" do
    setup [:create_email_address]

    @tag :skip
    test "renders form for editing chosen email_address", %{
      conn: conn,
      email_address: email_address
    } do
      conn = get(conn, Routes.email_address_path(conn, :edit, email_address))
      assert html_response(conn, 200) =~ "Edit Email address"
    end
  end

  describe "update email_address" do
    setup [:create_email_address]

    @tag :skip
    test "redirects when data is valid", %{conn: conn, email_address: email_address} do
      conn =
        put(conn, Routes.email_address_path(conn, :update, email_address),
          email_address: @update_attrs
        )

      assert redirected_to(conn) == Routes.email_address_path(conn, :show, email_address)

      conn = get(conn, Routes.email_address_path(conn, :show, email_address))
      assert html_response(conn, 200) =~ "some updated description"
    end

    @tag :skip
    test "renders errors when data is invalid", %{conn: conn, email_address: email_address} do
      conn =
        put(conn, Routes.email_address_path(conn, :update, email_address),
          email_address: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Email address"
    end
  end

  describe "delete email_address" do
    setup [:create_email_address]

    @tag :skip
    test "deletes chosen email_address", %{conn: conn, email_address: email_address} do
      conn = delete(conn, Routes.email_address_path(conn, :delete, email_address))
      assert redirected_to(conn) == Routes.email_address_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.email_address_path(conn, :show, email_address))
      end
    end
  end

  defp create_email_address(_) do
    email_address = fixture(:email_address)
    {:ok, email_address: email_address}
  end
end
