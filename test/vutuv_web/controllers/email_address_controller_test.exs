defmodule VutuvWeb.EmailAddressControllerTest do
  use VutuvWeb.ConnCase

  import VutuvWeb.AuthTestHelpers

  alias Vutuv.{Accounts, Accounts.User}

  @create_attrs %{
    "is_public" => true,
    "description" => "backup email",
    "value" => "abcdef@example.com"
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

    test "redirects unauthenticated user", %{user: user} do
      conn = build_conn()
      conn = get(conn, Routes.user_email_address_path(conn, :index, user))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
      assert get_flash(conn, :error) =~ "need to log in"
    end

    test "redirects unauthorized user", %{conn: conn, user: user} do
      other = add_user("raymond@example.com")
      conn = get(conn, Routes.user_email_address_path(conn, :index, other))
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      assert get_flash(conn, :error) =~ "not authorized"
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
      refute html_response(conn, 200) =~ "Value"
    end

    test "redirects unauthenticated user", %{user: user} do
      conn = build_conn()
      conn = get(conn, Routes.user_email_address_path(conn, :new, user))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
      assert get_flash(conn, :error) =~ "need to log in"
    end
  end

  describe "show email_address" do
    test "shows chosen email_address if it belongs to current_user", %{
      conn: conn,
      user: user,
      email_address: email_address
    } do
      conn = get(conn, Routes.user_email_address_path(conn, :show, user, email_address))
      assert html_response(conn, 200) =~ email_address.value
    end

    test "returns not found for non-existent email_address", %{conn: conn, user: user} do
      assert_error_sent 404, fn ->
        get(conn, Routes.user_email_address_path(conn, :show, user, -1))
      end
    end

    test "redirects when current_user is nil", %{user: user, email_address: email_address} do
      conn = build_conn()
      conn = get(conn, Routes.user_email_address_path(conn, :show, user, email_address))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
      assert get_flash(conn, :error) =~ "need to log in"
    end

    test "redirects when email_address does not belong to current_user", %{conn: conn, user: user} do
      %User{email_addresses: [email_address]} = other = add_user("raymond@example.com")

      assert_error_sent 404, fn ->
        get(conn, Routes.user_email_address_path(conn, :show, user, email_address))
      end

      conn = get(conn, Routes.user_email_address_path(conn, :show, other, email_address))
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      assert get_flash(conn, :error) =~ "not authorized"
    end
  end

  describe "create email_address" do
    test "creates and returns email_address when data is valid", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_email_address_path(conn, :create, user),
          email_address: @create_attrs
        )

      assert redirected_to(conn) ==
               Routes.verification_path(conn, :new, email: "abcdef@example.com")

      assert get_flash(conn, :info) =~ "created successfully"
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
      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end

    test "cannot create an email_address for another user", %{conn: conn, user: user} do
      other = add_user("raymond@example.com")

      conn =
        post(conn, Routes.user_email_address_path(conn, :create, other),
          email_address: @create_attrs
        )

      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      assert get_flash(conn, :error) =~ "not authorized"

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_email_address!(%{"value" => "abcdef@example.com"})
      end
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

      assert get_flash(conn, :info) =~ "updated successfully"
      email_address = Accounts.get_email_address!(user, %{"id" => email_address.id})
      assert email_address.is_public == false
    end

    test "does not update chosen email_address when data is invalid", %{
      conn: conn,
      user: user,
      email_address: email_address
    } do
      too_long = String.duplicate("too long", 32)

      conn =
        put(conn, Routes.user_email_address_path(conn, :update, user, email_address),
          email_address: %{"description" => too_long}
        )

      assert html_response(conn, 200) =~ "Edit email address"
      assert html_response(conn, 200) =~ "should be at most 255 character"
    end

    test "cannot update the email value", %{conn: conn, user: user, email_address: email_address} do
      conn =
        put(conn, Routes.user_email_address_path(conn, :update, user, email_address),
          email_address: %{"value" => "frannypoohs@example.com"}
        )

      assert html_response(conn, 200) =~ "Edit email address"
      email_address = Accounts.get_email_address!(user, %{"id" => email_address.id})
      assert email_address.is_public == true
    end

    test "cannot update an email_address for another user", %{conn: conn, user: user} do
      %User{email_addresses: [email_address]} = other = add_user("raymond@example.com")

      assert_error_sent 404, fn ->
        put(conn, Routes.user_email_address_path(conn, :update, user, email_address),
          email_address: %{"is_public" => false}
        )
      end

      email_address = Accounts.get_email_address!(other, %{"id" => email_address.id})
      assert email_address.is_public == true
    end
  end

  describe "delete email_address" do
    test "deletes chosen email_address", %{conn: conn, user: user, email_address: email_address} do
      conn = delete(conn, Routes.user_email_address_path(conn, :delete, user, email_address))
      assert redirected_to(conn) == Routes.user_email_address_path(conn, :index, user)
      assert get_flash(conn, :info) =~ "deleted successfully"

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_email_address!(user, %{"id" => email_address.id})
      end
    end

    test "cannot delete another user's email_address", %{conn: conn, user: user} do
      %User{email_addresses: [email_address]} = other = add_user("raymond@example.com")

      assert_error_sent 404, fn ->
        delete(conn, Routes.user_email_address_path(conn, :delete, user, email_address))
      end

      assert Accounts.get_email_address!(other, %{"id" => email_address.id})
    end
  end
end
