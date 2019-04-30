defmodule VutuvWeb.EmailAddressControllerTest do
  use VutuvWeb.ConnCase

  import VutuvWeb.AuthTestHelpers

  alias Vutuv.{Accounts, Accounts.User}

  @create_attrs %{
    "is_public" => true,
    "description" => "backup email",
    "value" => "abcdef@vutuv.com"
  }

  setup %{conn: conn} do
    conn = conn |> bypass_through(VutuvWeb.Router, [:browser]) |> get("/")
    %User{email_addresses: [email_address]} = user = add_user("igor@example.com")
    conn = conn |> add_session(user) |> send_resp(:ok, "/")
    {:ok, %{conn: conn, user: user, email_address: email_address}}
  end

  describe "index" do
    test "lists all entries on index", %{conn: conn, user: user, email_address: email_address} do
      conn = get(conn, Routes.user_email_address_path(conn, :index, user))
      assert html_response(conn, 200) =~ email_address.value
    end
  end

  describe "renders forms" do
    test "renders form for new email_addresses", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_email_address_path(conn, :new, user))
      assert html_response(conn, 200) =~ "New email address"
    end

    test "renders form for editing chosen email_address", %{
      conn: conn,
      user: user,
      email_address: email_address
    } do
      conn = get(conn, Routes.user_email_address_path(conn, :edit, user, email_address))
      assert html_response(conn, 200) =~ "Edit email address"
    end
  end

  describe "show email_address" do
    test "shows chosen email_address if it belongs to current_user", %{
      conn: conn,
      user: user,
      email_address: email_address
    } do
      conn = get(conn, Routes.user_email_address_path(conn, :show, user, email_address))
      assert html_response(conn, 200) =~ "Show email addres"
    end

    test "returns errors when current_user is nil", %{user: user, email_address: email_address} do
      conn = build_conn()
      conn = get(conn, Routes.user_email_address_path(conn, :show, user, email_address))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end

    test "returns errors when email_address does not belong to current_user", %{
      conn: conn,
      user: user,
      email_address: email_address
    } do
      other = add_user("raymond@example.com")
      conn = get(conn, Routes.user_email_address_path(conn, :show, other, email_address))
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
    end
  end

  describe "create email_address" do
    test "creates and returns email_address when data is valid", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_email_address_path(conn, :create, user),
          email_address: @create_attrs
        )

      email_address = Accounts.get_email_address_from_value("abcdef@vutuv.com")

      assert redirected_to(conn) ==
               Routes.user_email_address_path(conn, :show, user, email_address)
    end

    test "does not create email_address when data is invalid", %{
      conn: conn,
      user: user
    } do
      conn =
        post(conn, Routes.user_email_address_path(conn, :create, user),
          email_address: %{"value" => ""}
        )

      assert html_response(conn, 200) =~ "New email address"
    end
  end

  describe "update email_address" do
    test "updates and returns chosen email_address when data is valid", %{
      conn: conn,
      user: user,
      email_address: email_address
    } do
      conn =
        put(conn, Routes.user_email_address_path(conn, :update, user, email_address),
          email_address: %{"is_public" => false}
        )

      assert redirected_to(conn) ==
               Routes.user_email_address_path(conn, :show, user, email_address)

      email_address = Accounts.get_email_address(email_address.id)
      assert email_address.is_public == false
    end

    test "does not update chosen email_address when data is invalid", %{
      conn: conn,
      user: user,
      email_address: email_address
    } do
      conn =
        put(conn, Routes.user_email_address_path(conn, :update, user, email_address),
          email_address: %{"value" => ""}
        )

      assert html_response(conn, 200) =~ "Edit email address"
    end
  end

  describe "delete email_address" do
    test "deletes chosen email_address", %{conn: conn, user: user, email_address: email_address} do
      conn = delete(conn, Routes.user_email_address_path(conn, :delete, user, email_address))
      assert redirected_to(conn) == Routes.user_email_address_path(conn, :index, user)
      refute Accounts.get_email_address(email_address.id)
    end
  end
end
