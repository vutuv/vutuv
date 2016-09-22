defmodule Vutuv.OAuthProviderControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.OAuthProvider
  @valid_attrs %{}
  @invalid_attrs %{}

  # test "lists all entries on index", %{conn: conn} do
  #   conn = get conn, user_o_auth_provider_path(conn, :index, conn.assigns[:current_user])
  #   assert html_response(conn, 200) =~ "Listing oauth providers"
  # end

  # test "renders form for new resources", %{conn: conn} do
  #   conn = get conn, user_o_auth_provider_path(conn, :new, conn.assigns[:current_user])
  #   assert html_response(conn, 200) =~ "New o auth provider"
  # end

  # test "creates resource and redirects when data is valid", %{conn: conn} do
  #   conn = post conn, user_o_auth_provider_path(conn, :create, conn.assigns[:current_user]), o_auth_provider: @valid_attrs
  #   assert redirected_to(conn) == user_o_auth_provider_path(conn, :index, conn.assigns[:current_user])
  #   assert Repo.get_by(OAuthProvider, @valid_attrs)
  # end

  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, user_o_auth_provider_path(conn, :create, conn.assigns[:current_user]), o_auth_provider: @invalid_attrs
  #   assert html_response(conn, 200) =~ "New o auth provider"
  # end

  # test "shows chosen resource", %{conn: conn} do
  #   o_auth_provider = Repo.insert! %OAuthProvider{}
  #   conn = get conn, user_o_auth_provider_path(conn, :show, conn.assigns[:current_user], o_auth_provider)
  #   assert html_response(conn, 200) =~ "Show o auth provider"
  # end

  # test "renders page not found when id is nonexistent", %{conn: conn} do
  #   assert_error_sent 404, fn ->
  #     get conn, user_o_auth_provider_path(conn, :show, conn.assigns[:current_user], -1)
  #   end
  # end

  # test "renders form for editing chosen resource", %{conn: conn} do
  #   o_auth_provider = Repo.insert! %OAuthProvider{}
  #   conn = get conn, user_o_auth_provider_path(conn, :edit, conn.assigns[:current_user], o_auth_provider)
  #   assert html_response(conn, 200) =~ "Edit o auth provider"
  # end

  # test "updates chosen resource and redirects when data is valid", %{conn: conn} do
  #   o_auth_provider = Repo.insert! %OAuthProvider{}
  #   conn = put conn, user_o_auth_provider_path(conn, :update, conn.assigns[:current_user], o_auth_provider), o_auth_provider: @valid_attrs
  #   assert redirected_to(conn) == user_o_auth_provider_path(conn, :show, conn.assigns[:current_user], o_auth_provider)
  #   assert Repo.get_by(OAuthProvider, @valid_attrs)
  # end

  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   o_auth_provider = Repo.insert! %OAuthProvider{}
  #   conn = put conn, user_o_auth_provider_path(conn, :update, conn.assigns[:current_user], o_auth_provider), o_auth_provider: @invalid_attrs
  #   assert html_response(conn, 200) =~ "Edit o auth provider"
  # end

  # test "deletes chosen resource", %{conn: conn} do
  #   o_auth_provider = Repo.insert! %OAuthProvider{}
  #   conn = delete conn, user_o_auth_provider_path(conn, :delete, o_auth_provider)
  #   assert redirected_to(conn) == user_o_auth_provider_path(conn, :index, conn.assigns[:current_user])
  #   refute Repo.get(OAuthProvider, o_auth_provider.id)
  # end
end
