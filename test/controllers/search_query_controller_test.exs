defmodule Vutuv.SearchQueryControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.SearchQuery
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, search_query_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing search queries"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, search_query_path(conn, :new)
    assert html_response(conn, 200) =~ "New search query"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, search_query_path(conn, :create), search_query: @valid_attrs
    assert redirected_to(conn) == search_query_path(conn, :index)
    assert Repo.get_by(SearchQuery, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, search_query_path(conn, :create), search_query: @invalid_attrs
    assert html_response(conn, 200) =~ "New search query"
  end

  test "shows chosen resource", %{conn: conn} do
    search_query = Repo.insert! %SearchQuery{}
    conn = get conn, search_query_path(conn, :show, search_query)
    assert html_response(conn, 200) =~ "Show search query"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, search_query_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    search_query = Repo.insert! %SearchQuery{}
    conn = get conn, search_query_path(conn, :edit, search_query)
    assert html_response(conn, 200) =~ "Edit search query"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    search_query = Repo.insert! %SearchQuery{}
    conn = put conn, search_query_path(conn, :update, search_query), search_query: @valid_attrs
    assert redirected_to(conn) == search_query_path(conn, :show, search_query)
    assert Repo.get_by(SearchQuery, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    search_query = Repo.insert! %SearchQuery{}
    conn = put conn, search_query_path(conn, :update, search_query), search_query: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit search query"
  end

  test "deletes chosen resource", %{conn: conn} do
    search_query = Repo.insert! %SearchQuery{}
    conn = delete conn, search_query_path(conn, :delete, search_query)
    assert redirected_to(conn) == search_query_path(conn, :index)
    refute Repo.get(SearchQuery, search_query.id)
  end
end
