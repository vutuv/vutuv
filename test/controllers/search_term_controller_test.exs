defmodule Vutuv.SearchTermControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.SearchTerm
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, search_term_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing search terms"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, search_term_path(conn, :new)
    assert html_response(conn, 200) =~ "New search term"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, search_term_path(conn, :create), search_term: @valid_attrs
    assert redirected_to(conn) == search_term_path(conn, :index)
    assert Repo.get_by(SearchTerm, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, search_term_path(conn, :create), search_term: @invalid_attrs
    assert html_response(conn, 200) =~ "New search term"
  end

  test "shows chosen resource", %{conn: conn} do
    search_term = Repo.insert! %SearchTerm{}
    conn = get conn, search_term_path(conn, :show, search_term)
    assert html_response(conn, 200) =~ "Show search term"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, search_term_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    search_term = Repo.insert! %SearchTerm{}
    conn = get conn, search_term_path(conn, :edit, search_term)
    assert html_response(conn, 200) =~ "Edit search term"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    search_term = Repo.insert! %SearchTerm{}
    conn = put conn, search_term_path(conn, :update, search_term), search_term: @valid_attrs
    assert redirected_to(conn) == search_term_path(conn, :show, search_term)
    assert Repo.get_by(SearchTerm, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    search_term = Repo.insert! %SearchTerm{}
    conn = put conn, search_term_path(conn, :update, search_term), search_term: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit search term"
  end

  test "deletes chosen resource", %{conn: conn} do
    search_term = Repo.insert! %SearchTerm{}
    conn = delete conn, search_term_path(conn, :delete, search_term)
    assert redirected_to(conn) == search_term_path(conn, :index)
    refute Repo.get(SearchTerm, search_term.id)
  end
end
