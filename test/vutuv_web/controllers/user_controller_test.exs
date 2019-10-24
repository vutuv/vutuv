defmodule VutuvWeb.UserControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.UserProfiles

  @create_attrs %{
    "email" => "bill@example.com",
    "password" => "reallyHard2gue$$",
    "gender" => "male",
    "full_name" => "bill shakespeare"
  }

  setup %{conn: conn} do
    conn = conn |> bypass_through(VutuvWeb.Router, [:browser]) |> get("/")
    {:ok, %{conn: conn}}
  end

  describe "read user data" do
    test "lists all entries on index", %{conn: conn} do
      users = insert_list(12, :user)
      first_page_user = Enum.at(users, 5)
      second_page_user = Enum.at(UserProfiles.list_users(), -1)
      conn = get(conn, Routes.user_path(conn, :index))
      response = html_response(conn, 200)
      assert response =~ "Users"
      assert response =~ "Previous"
      assert response =~ "Next"
      assert response =~ first_page_user.slug
      refute response =~ second_page_user.slug
    end

    test "show current user's page", %{conn: conn} do
      user = insert(:user)
      {:ok, %{conn: conn, user: user}} = add_session_to_conn(%{conn: conn, user: user})
      user = add_user_assocs(user)
      conn = get(conn, Routes.user_path(conn, :show, user))
      response = html_response(conn, 200)
      assert response =~ "4 followers"
      assert response =~ "Email addresses"
      assert response =~ "View profile"
    end

    test "show other user's page - no edit links", %{conn: conn} do
      user = add_user("reg@example.com")
      conn = get(conn, Routes.user_path(conn, :show, user))
      response = html_response(conn, 200)
      assert response =~ ~r/Email addresses(.|\n)*Followers/
      refute response =~ "Edit email"
    end

    test "shows 404 for non-existent user", %{conn: conn} do
      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, "Raymond.Luxury.Yacht"))
      end
    end
  end

  describe "renders forms" do
    setup [:create_user, :add_session_to_conn]

    test "renders form for new users" do
      conn = build_conn()
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "Sign up"
    end

    test "new route redirects to show if user is logged in", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
    end

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ ~r/Edit user(.|\n)*#{DateTime.utc_now().year}/
    end
  end

  describe "create user data" do
    test "successful when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)

      assert redirected_to(conn) ==
               Routes.verification_path(conn, :new, email: @create_attrs["email"])

      assert UserProfiles.get_user!(%{"email" => "bill@example.com"})
    end

    test "does not return an error when the email has been taken", %{conn: conn} do
      UserProfiles.create_user(@create_attrs)
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)

      assert redirected_to(conn) ==
               Routes.verification_path(conn, :new, email: @create_attrs["email"])

      assert get_flash(conn, :info) =~ "confirm your account"
    end

    test "fails and renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: %{email: "mustard@example.com"})
      assert html_response(conn, 200) =~ "can&#39;t be blank"

      assert_raise Ecto.NoResultsError, fn ->
        UserProfiles.get_user!(%{"email" => "mustard@example.com"})
      end
    end
  end

  describe "update user data" do
    setup [:create_user, :add_session_to_conn]

    test "successful when data is valid", %{conn: conn, user: user} do
      attrs = %{"full_name" => "Raymond Luxury Yacht"}
      conn = put(conn, Routes.user_path(conn, :update, user), user: attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      updated_user = UserProfiles.get_user!(%{"id" => user.id})
      assert updated_user.full_name == "Raymond Luxury Yacht"
      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "Raymond Luxury Yacht"
    end

    test "updates locale data when locale is supported", %{conn: conn, user: user} do
      attrs = %{"locale" => "de_CH"}
      conn = put(conn, Routes.user_path(conn, :update, user), user: attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      updated_user = UserProfiles.get_user!(%{"id" => user.id})
      assert updated_user.locale == "de_CH"
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "de_CH"
    end

    test "fails when data is invalid", %{conn: conn, user: user} do
      attrs = %{"honorific_prefix" => String.duplicate("Dr", 42)}
      conn = put(conn, Routes.user_path(conn, :update, user), user: attrs)
      assert html_response(conn, 200) =~ ~r/Edit user(.|\n)*DrDrDrDrDrDrDrDr/
    end
  end

  describe "delete user" do
    setup [:create_user, :add_session_to_conn]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
      assert_raise Ecto.NoResultsError, fn -> UserProfiles.get_user!(%{"id" => user.id}) end
    end

    test "cannot delete other user", %{conn: conn, user: user} do
      other = add_user("tony@example.com")
      conn = delete(conn, Routes.user_path(conn, :delete, other))
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      assert UserProfiles.get_user!(%{"id" => other.id})
    end
  end

  defp create_user(%{conn: conn}) do
    user = add_user("reg@example.com")
    {:ok, %{conn: conn, user: user}}
  end
end
