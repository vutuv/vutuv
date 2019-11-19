defmodule VutuvWeb.Api.AddressControllerTest do
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
    user = add_user("igor@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "read addresses" do
    test "lists a user's addresses", %{conn: conn, user: user} do
      address = insert(:address, %{user: user})
      conn = get(conn, Routes.api_user_address_path(conn, :index, user))
      assert [new_address] = json_response(conn, 200)["data"]
      assert new_address == single_response(address)
    end

    test "shows a specific public address", %{conn: conn, user: user} do
      address = insert(:address, %{user: user})
      conn = get(conn, Routes.api_user_address_path(conn, :show, user, address))
      assert json_response(conn, 200)["data"] == single_response(address)
    end
  end

  describe "write addresses" do
    setup [:add_token_to_conn]

    test "create address with valid data", %{conn: conn, user: user} do
      conn = post(conn, Routes.api_user_address_path(conn, :create, user), address: @create_attrs)
      assert json_response(conn, 201)["data"]["id"]
      [new_address] = UserProfiles.list_addresses(user)
      assert new_address.city == @create_attrs[:city]
      assert new_address.country == @create_attrs[:country]
    end

    test "does not create address when data is invalid", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.api_user_address_path(conn, :create, user), address: %{"country" => ""})

      assert json_response(conn, 422)["errors"]["country"] == ["can't be blank"]
    end

    test "update address with valid data", %{conn: conn, user: user} do
      address = insert(:address, %{user: user})

      conn =
        put(conn, Routes.api_user_address_path(conn, :update, user, address),
          address: %{"line_1" => "212B"}
        )

      assert json_response(conn, 200)["data"]["id"]
      address = UserProfiles.get_address!(user, address.id)
      assert address.line_1 =~ "212B"
    end

    test "does not update address when data is invalid", %{conn: conn, user: user} do
      address = insert(:address, %{user: user})

      conn =
        put(conn, Routes.api_user_address_path(conn, :update, user, address),
          address: %{"description" => ""}
        )

      assert json_response(conn, 422)["errors"]["description"] == ["can't be blank"]
    end
  end

  describe "delete address" do
    setup [:add_token_to_conn]

    test "can delete chosen address", %{conn: conn, user: user} do
      address = insert(:address, %{user: user})
      conn = delete(conn, Routes.api_user_address_path(conn, :delete, user, address))
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn ->
        UserProfiles.get_address!(user, address.id)
      end
    end

    test "cannot delete another user's address", %{conn: conn, user: user} do
      other = add_user("raymond@example.com")
      address = insert(:address, %{user: other})

      assert_error_sent 404, fn ->
        delete(conn, Routes.api_user_address_path(conn, :delete, user, address))
      end

      assert UserProfiles.get_address!(other, address.id)
    end
  end

  defp single_response(address) do
    %{
      "id" => address.id,
      "user_id" => address.user_id,
      "city" => address.city,
      "country" => address.country,
      "description" => address.description,
      "line_1" => address.line_1,
      "line_2" => address.line_2,
      "line_3" => address.line_3,
      "line_4" => address.line_4,
      "state" => address.state,
      "zip_code" => address.zip_code
    }
  end
end
