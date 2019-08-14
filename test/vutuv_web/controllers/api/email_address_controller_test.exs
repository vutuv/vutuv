defmodule VutuvWeb.Api.EmailAddressControllerTest do
  use VutuvWeb.ConnCase

  import VutuvWeb.AuthTestHelpers

  alias Vutuv.{Accounts.User, Devices}

  @create_attrs %{
    "is_public" => true,
    "description" => "backup email",
    "value" => "abcdef@example.com"
  }

  setup %{conn: conn} do
    %User{email_addresses: [email_address]} = user = add_user("igor@example.com")
    conn = conn |> add_token_conn(user)
    {:ok, %{conn: conn, user: user, email_address: email_address}}
  end

  describe "index" do
    test "lists all entries on index", %{conn: conn, user: user, email_address: email_address} do
      conn = get(conn, Routes.api_user_email_address_path(conn, :index, user))

      assert json_response(conn, 200)["data"] == [
               %{
                 "id" => email_address.id,
                 "user_id" => email_address.user_id,
                 "value" => email_address.value
               }
             ]
    end
  end

  describe "show email_address" do
    test "shows chosen email_address if it belongs to current_user", %{
      conn: conn,
      user: user,
      email_address: email_address
    } do
      conn = get(conn, Routes.api_user_email_address_path(conn, :show, user, email_address))

      assert json_response(conn, 200)["data"] == %{
               "id" => email_address.id,
               "user_id" => email_address.user_id,
               "value" => email_address.value
             }
    end

    test "returns errors when current_user is nil", %{user: user, email_address: email_address} do
      conn =
        build_conn()
        |> put_req_header("accept", "application/json")
        |> get(Routes.api_user_email_address_path(build_conn(), :show, user, email_address))

      assert json_response(conn, 401)["errors"]["detail"] =~ "need to login"
    end

    test "returns errors when email_address does not belong to current_user", %{
      conn: conn,
      user: user
    } do
      %User{email_addresses: [email_address]} = other = add_user("fred@mail.com")

      assert_error_sent 404, fn ->
        get(conn, Routes.api_user_email_address_path(conn, :show, user, email_address))
      end

      conn = get(conn, Routes.api_user_email_address_path(conn, :show, other, email_address))
      assert json_response(conn, 403)["errors"]["detail"] =~ "are not authorized"
    end
  end

  describe "create email_address" do
    test "creates and returns email_address when data is valid", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.api_user_email_address_path(conn, :create, user),
          email_address: @create_attrs
        )

      assert json_response(conn, 201)["data"]["id"]
      assert Devices.get_email_address(%{"value" => @create_attrs["value"]})
    end

    test "does not create email_address and returns errors when data is invalid", %{
      conn: conn,
      user: user
    } do
      conn =
        post(conn, Routes.api_user_email_address_path(conn, :create, user),
          email_address: %{"value" => ""}
        )

      assert json_response(conn, 422)["errors"]["value"] == ["can't be blank"]
    end
  end

  describe "update email_address" do
    test "updates and returns chosen email_address when data is valid", %{
      conn: conn,
      user: user,
      email_address: email_address
    } do
      conn =
        put(conn, Routes.api_user_email_address_path(conn, :update, user, email_address),
          email_address: %{"is_public" => false}
        )

      assert json_response(conn, 200)["data"]["id"]
      assert Devices.get_email_address!(user, email_address.id)
    end

    test "does not update chosen email_address when data is invalid", %{
      conn: conn,
      user: user,
      email_address: email_address
    } do
      too_long = String.duplicate("too long", 32)

      conn =
        put(conn, Routes.api_user_email_address_path(conn, :update, user, email_address),
          email_address: %{"description" => too_long}
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete email_address" do
    test "deletes chosen email_address", %{conn: conn, user: user, email_address: email_address} do
      conn = delete(conn, Routes.api_user_email_address_path(conn, :delete, user, email_address))
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn ->
        Devices.get_email_address!(user, email_address.id)
      end
    end

    test "cannot delete other user's email_address", %{conn: conn, user: user} do
      %User{email_addresses: [email_address]} = other = add_user("raymond@example.com")

      assert_error_sent 404, fn ->
        delete(conn, Routes.api_user_email_address_path(conn, :delete, user, email_address))
      end

      assert Devices.get_email_address!(other, email_address.id)
    end
  end
end
