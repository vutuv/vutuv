defmodule VutuvWeb.AddressControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.UserProfiles

  @create_attrs %{
    city: "London",
    country: "UK",
    description: "Home address",
    line_1: "221B",
    line_2: "Baker St",
    line_3: "Marylebone",
    line_4: "",
    state: "London",
    zip_code: "NW1 6XE"
  }

  setup %{conn: conn} do
    conn = conn |> bypass_through(VutuvWeb.Router, [:browser]) |> get("/")
    user = add_user("igor@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "read addresses" do
    test "lists a user's addresses", %{conn: conn, user: user} do
      address = insert(:address, %{user: user})
      conn = get(conn, Routes.user_address_path(conn, :index, user))
      assert html_response(conn, 200) =~ address.country
    end

    test "shows a specific public address", %{conn: conn, user: user} do
      address = insert(:address, %{user: user})
      conn = get(conn, Routes.user_address_path(conn, :show, user, address))
      assert html_response(conn, 200) =~ address.country
    end
  end

  describe "renders forms" do
    setup [:add_user_session]

    test "new address form", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_address_path(conn, :new, user))
      assert html_response(conn, 200) =~ "New address"
    end

    test "edit address form", %{conn: conn, user: user} do
      address = insert(:address, %{user: user})
      conn = get(conn, Routes.user_address_path(conn, :edit, user, address))
      assert html_response(conn, 200) =~ "Edit address"
    end
  end

  describe "write addresses" do
    setup [:add_user_session]

    test "create address with valid data", %{conn: conn, user: user} do
      conn = post(conn, Routes.user_address_path(conn, :create, user), address: @create_attrs)
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_address_path(conn, :show, user, id)
      assert get_flash(conn, :info) =~ "created successfully"
    end

    test "does not create address when data is invalid", %{conn: conn, user: user} do
      conn = post(conn, Routes.user_address_path(conn, :create, user), address: %{"body" => ""})
      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end

    test "update address with valid data", %{conn: conn, user: user} do
      address = insert(:address, %{user: user})

      conn =
        put(conn, Routes.user_address_path(conn, :update, user, address),
          address: %{"line_1" => "212B"}
        )

      assert redirected_to(conn) == Routes.user_address_path(conn, :show, user, address)
      assert get_flash(conn, :info) =~ "updated successfully"
      address = UserProfiles.get_address!(user, address.id)
      assert address.line_1 =~ "212B"
    end

    test "does not update address when data is invalid", %{conn: conn, user: user} do
      address = insert(:address, %{user: user})

      conn =
        put(conn, Routes.user_address_path(conn, :update, user, address),
          address: %{"description" => ""}
        )

      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end
  end

  describe "delete address" do
    setup [:add_user_session]

    test "can delete chosen address", %{conn: conn, user: user} do
      address = insert(:address, %{user: user})
      conn = delete(conn, Routes.user_address_path(conn, :delete, user, address))
      assert redirected_to(conn) == Routes.user_address_path(conn, :index, user)
      assert get_flash(conn, :info) =~ "deleted successfully"
      assert_raise Ecto.NoResultsError, fn -> UserProfiles.get_address!(user, address.id) end
    end

    test "cannot delete another user's address", %{conn: conn, user: user} do
      other = add_user("raymond@example.com")
      address = insert(:address, %{user: other})

      assert_error_sent 404, fn ->
        delete(conn, Routes.user_address_path(conn, :delete, user, address))
      end

      assert UserProfiles.get_address!(other, address.id)
    end
  end

  defp add_user_session(%{conn: conn, user: user}) do
    conn = conn |> add_session(user) |> send_resp(:ok, "/")
    {:ok, %{conn: conn, user: user}}
  end
end
