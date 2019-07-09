defmodule VutuvWeb.Api.UserControllerTest do
  use VutuvWeb.ConnCase

  import VutuvWeb.AuthTestHelpers

  alias Vutuv.Accounts

  @create_attrs %{
    "email" => "bill@example.com",
    "password" => "reallyHard2gue$$",
    "gender" => "male",
    "full_name" => "bill shakespeare"
  }

  describe "read user data" do
    test "lists all entries on index", %{conn: conn} do
      user = add_user("reg@example.com")
      conn = conn |> add_token_conn(user)
      conn = get(conn, Routes.api_user_path(conn, :index))
      assert json_response(conn, 200)
    end

    test "show chosen user's resource", %{conn: conn} do
      user = add_user("reg@example.com")
      conn = get(conn, Routes.api_user_path(conn, :show, user))

      assert json_response(conn, 200)["data"] == %{
               "id" => user.id,
               "full_name" => user.full_name,
               "slug" => user.slug
             }
    end
  end

  describe "create user" do
    test "creates user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.api_user_path(conn, :create), user: @create_attrs)
      assert json_response(conn, 201)["data"]["id"]
      assert Accounts.get_user(%{"email" => "bill@example.com"})
    end

    test "does not create user and renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.api_user_path(conn, :create), user: %{email: nil})

      assert json_response(conn, 422)["errors"]["email_addresses"] == [
               %{"value" => ["can't be blank"]}
             ]
    end
  end

  describe "updates user" do
    setup [:add_user_session]

    test "updates chosen user when data is valid", %{conn: conn, user: user} do
      attrs = %{"full_name" => "Raymond Luxury Yacht"}
      conn = put(conn, Routes.api_user_path(conn, :update, user), user: attrs)
      assert json_response(conn, 200)["data"]["id"] == user.id
      updated_user = Accounts.get_user(%{"user_id" => user.id})
      assert updated_user.full_name == "Raymond Luxury Yacht"
    end

    test "does not update chosen user and renders errors when data is invalid", %{
      conn: conn,
      user: user
    } do
      attrs = %{"honorific_prefix" => String.duplicate("Dr", 42)}
      conn = put(conn, Routes.api_user_path(conn, :update, user), user: attrs)

      assert json_response(conn, 422)["errors"] == %{
               "honorific_prefix" => ["should be at most 80 character(s)"]
             }
    end
  end

  describe "delete user" do
    setup [:add_user_session]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.api_user_path(conn, :delete, user))
      assert response(conn, 204)
      refute Accounts.get_user(%{"user_id" => user.id})
    end

    test "cannot delete other user", %{conn: conn} do
      other = add_user("tony@example.com")
      conn = delete(conn, Routes.api_user_path(conn, :delete, other))
      assert json_response(conn, 403)["errors"]["detail"] =~ "not authorized"
      assert Accounts.get_user(%{"user_id" => other.id})
    end
  end

  defp add_user_session(%{conn: conn}) do
    user = add_user("reg@example.com")
    conn = conn |> add_token_conn(user)
    {:ok, %{conn: conn, user: user}}
  end
end
