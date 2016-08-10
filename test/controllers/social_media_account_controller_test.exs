defmodule Vutuv.SocialMediaAccountControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.SocialMediaAccount
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, social_media_account_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing social media accounts"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, social_media_account_path(conn, :new)
    assert html_response(conn, 200) =~ "New social media account"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, social_media_account_path(conn, :create), social_media_account: @valid_attrs
    assert redirected_to(conn) == social_media_account_path(conn, :index)
    assert Repo.get_by(SocialMediaAccount, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, social_media_account_path(conn, :create), social_media_account: @invalid_attrs
    assert html_response(conn, 200) =~ "New social media account"
  end

  test "shows chosen resource", %{conn: conn} do
    social_media_account = Repo.insert! %SocialMediaAccount{}
    conn = get conn, social_media_account_path(conn, :show, social_media_account)
    assert html_response(conn, 200) =~ "Show social media account"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, social_media_account_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    social_media_account = Repo.insert! %SocialMediaAccount{}
    conn = get conn, social_media_account_path(conn, :edit, social_media_account)
    assert html_response(conn, 200) =~ "Edit social media account"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    social_media_account = Repo.insert! %SocialMediaAccount{}
    conn = put conn, social_media_account_path(conn, :update, social_media_account), social_media_account: @valid_attrs
    assert redirected_to(conn) == social_media_account_path(conn, :show, social_media_account)
    assert Repo.get_by(SocialMediaAccount, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    social_media_account = Repo.insert! %SocialMediaAccount{}
    conn = put conn, social_media_account_path(conn, :update, social_media_account), social_media_account: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit social media account"
  end

  test "deletes chosen resource", %{conn: conn} do
    social_media_account = Repo.insert! %SocialMediaAccount{}
    conn = delete conn, social_media_account_path(conn, :delete, social_media_account)
    assert redirected_to(conn) == social_media_account_path(conn, :index)
    refute Repo.get(SocialMediaAccount, social_media_account.id)
  end
end
