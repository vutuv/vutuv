defmodule Vutuv.SearchTermControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.SearchTerm
  @valid_attrs %{}
  @invalid_attrs %{}

  # test "lists all entries on index", %{conn: conn} do
  #   conn = get conn, user_search_term_path(conn, :index, conn.assigns[:current_user])
  #   assert html_response(conn, 200) =~ "Listing search terms"
  # end

  # test "renders form for new resources", %{conn: conn} do
  #   conn = get conn, user_search_term_path(conn, :new, conn.assigns[:current_user])
  #   assert html_response(conn, 200) =~ "New search term"
  # end

  # test "creates resource and redirects when data is valid", %{conn: conn} do
  #   conn = post conn, user_search_term_path(conn, :create, conn.assigns[:current_user]), search_term: @valid_attrs
  #   assert redirected_to(conn) == user_search_term_path(conn, :index, conn.assigns[:current_user])
  #   assert Repo.get_by(SearchTerm, @valid_attrs)
  # end

  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, user_search_term_path(conn, :create, conn.assigns[:current_user]), search_term: @invalid_attrs
  #   assert html_response(conn, 200) =~ "New search term"
  # end

  # test "shows chosen resource", %{conn: conn} do
  #   search_term = Repo.insert! %SearchTerm{}
  #   conn = get conn, user_search_term_path(conn, :show, conn.assigns[:current_user], search_term)
  #   assert html_response(conn, 200) =~ "Show search term"
  # end

  # test "renders page not found when id is nonexistent", %{conn: conn} do
  #   assert_error_sent 404, fn ->
  #     get conn, user_search_term_path(conn, :show, conn.assigns[:current_user], -1)
  #   end
  # end

  # test "renders form for editing chosen resource", %{conn: conn} do
  #   search_term = Repo.insert! %SearchTerm{}
  #   conn = get conn, user_search_term_path(conn, :edit, conn.assigns[:current_user], search_term)
  #   assert html_response(conn, 200) =~ "Edit search term"
  # end

  # test "updates chosen resource and redirects when data is valid", %{conn: conn} do
  #   search_term = Repo.insert! %SearchTerm{}
  #   conn = put conn, user_search_term_path(conn, :update, conn.assigns[:current_user], search_term), search_term: @valid_attrs
  #   assert redirected_to(conn) == user_search_term_path(conn, :show, conn.assigns[:current_user], search_term)
  #   assert Repo.get_by(SearchTerm, @valid_attrs)
  # end

  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   search_term = Repo.insert! %SearchTerm{}
  #   conn = put conn, user_search_term_path(conn, :update, conn.assigns[:current_user], search_term), search_term: @invalid_attrs
  #   assert html_response(conn, 200) =~ "Edit search term"
  # end

  # test "deletes chosen resource", %{conn: conn} do
  #   search_term = Repo.insert! %SearchTerm{}
  #   conn = delete conn, user_search_term_path(conn, :delete, conn.assigns[:current_user], search_term)
  #   assert redirected_to(conn) == user_search_term_path(conn, :index, conn.assigns[:current_user])
  #   refute Repo.get(SearchTerm, search_term.id)
  # end
end
