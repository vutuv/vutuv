defmodule Vutuv.UserControllerTest do
  use Vutuv.ConnCase
  use Bamboo.Test, shared: true
  alias Vutuv.Registration

  alias Vutuv.User
  @valid_attrs %{"emails" => %{"0" => %{"value" => "email@example.com"}},"first_name" => "first_name"}
  @update_attrs [first_name: "new_first_name"]
  @invalid_update_attrs [first_name: nil, last_name: nil]
  @invalid_attrs %{"emails" => %{"0" => %{"value" => nil}}, "first_name" => nil, "gender" => "male", "last_name" => nil}

  test "creates resource when valid and redirects", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    assert Repo.one(from u in User, join: e in assoc(u, :emails), where: e.value == ^@valid_attrs["emails"]["0"]["value"])
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "New user"
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "New user"
  end

  test "shows chosen resource", %{conn: conn} do
    {conn, user} = create_and_login_user conn
    conn = get conn, user_path(conn, :show, user)
    assert html_response(conn, 200) =~ user.first_name
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    conn = get conn, user_path(conn, :show, %User{active_slug: "1"})
    assert html_response(conn, :not_found)
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    {conn, user} = create_and_login_user conn
    conn = get conn, user_path(conn, :edit, user)
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    {conn, user} = create_and_login_user conn
    conn = put conn, user_path(conn, :update, user), user: @update_attrs
    assert redirected_to(conn) == user_path(conn, :show, user)
    assert Repo.get_by(User, @update_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    {conn, user} = create_and_login_user conn
    conn = put conn, user_path(conn, :update, user), user: @invalid_update_attrs
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "deletes chosen resource", %{conn: conn} do
    {conn, user} = create_and_login_user conn
    conn = delete conn, user_path(conn, :delete, user)
    link = Repo.one(from m in Vutuv.MagicLink, where: m.user_id == ^user.id and m.magic_link_type == "delete", select: m.magic_link)
    conn = get conn, user_path(conn, :magic_delete, link)
    assert redirected_to(conn) == page_path(conn, :index)
    refute Repo.get(User, user.id)
  end

  defp create_and_login_user(conn) do
    {:ok, user} = Registration.register_user(conn, @valid_attrs)
    Vutuv.Auth.login_by_email(conn, @valid_attrs["emails"]["0"]["value"])
    link = Repo.one(from m in Vutuv.MagicLink, where: m.user_id == ^user.id and m.magic_link_type == "login", select: m.magic_link)
    conn = get conn, session_path(conn, :show, link)
    {conn, user}
  end
end
