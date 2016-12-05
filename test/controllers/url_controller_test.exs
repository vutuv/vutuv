defmodule Vutuv.UrlControllerTest do
  use Vutuv.ConnCase, async: true

  import Vutuv.Factory

  alias Vutuv.Registration

  @valid_attrs %{"emails" => %{"0" => %{"value" => "email@example.com"}},"first_name" => "first_name"}

  test "show all urls", %{conn: conn} do
    {conn, user} = create_and_login_user(conn)
    conn = get conn, user_url_path(conn, :index, user)
    assert html_response(conn, 200) =~ "html"
  end

  test "redirect when creating valid url", %{conn: conn} do
    conn = create_url(conn, "example.org")
    assert html_response(conn, 302) =~ "html"
  end

  test "return 400 when creating invalid url", %{conn: conn} do
    conn = create_url(conn, "invalid_url")
    assert html_response(conn, 400) =~ "html"
  end

  test "return 400 when creating empty url", %{conn: conn} do
    conn = create_url(conn, "")
    assert html_response(conn, 400) =~ "html"
  end

  test "redirect when setting valid url", %{conn: conn} do
    conn = set_url(conn, "example.org")
    assert html_response(conn, 302) =~ "html"
  end

  test "return 400 when setting invalid url", %{conn: conn} do
    conn = set_url(conn, "invalid_url")
    assert html_response(conn, 400) =~ "html"
  end

  test "return 400 when setting empty url", %{conn: conn} do
    conn = set_url(conn, "")
    assert html_response(conn, 400) =~ "html"
  end

  test "redirect when deleting url", %{conn: conn} do
    {conn, user} = create_and_login_user(conn)
    url = insert(:url, user: user)
    conn = delete conn, user_url_path(conn, :delete, user, url)
    assert html_response(conn, 302) =~ "html"
  end

  defp create_url(conn, url_value) do
    {conn, user} = create_and_login_user(conn)
    post conn, user_url_path(conn, :create, user), url: %{"value" => url_value, "description" => "test"}
  end

  defp set_url(conn, url_value) do
    {conn, user} = create_and_login_user(conn)
    url = insert(:url, user: user)
    put conn, user_url_path(conn, :update, user, url), url: %{"value" => url_value, "description" => "test"}
  end

  defp create_and_login_user(conn) do
    {:ok, user} = Registration.register_user(conn, @valid_attrs)
    Vutuv.Auth.login_by_email(conn, @valid_attrs["emails"]["0"]["value"])
    link = Repo.one(from m in Vutuv.MagicLink, where: m.user_id == ^user.id and m.magic_link_type == "login", select: m.magic_link)
    conn = get conn, session_path(conn, :show, link)
    {conn, user}
  end
end
