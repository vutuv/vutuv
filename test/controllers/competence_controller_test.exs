defmodule Vutuv.CompetenceControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.Competence
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, competence_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing competences"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, competence_path(conn, :new)
    assert html_response(conn, 200) =~ "New competence"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, competence_path(conn, :create), competence: @valid_attrs
    assert redirected_to(conn) == competence_path(conn, :index)
    assert Repo.get_by(Competence, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, competence_path(conn, :create), competence: @invalid_attrs
    assert html_response(conn, 200) =~ "New competence"
  end

  test "shows chosen resource", %{conn: conn} do
    competence = Repo.insert! %Competence{}
    conn = get conn, competence_path(conn, :show, competence)
    assert html_response(conn, 200) =~ "Show competence"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, competence_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    competence = Repo.insert! %Competence{}
    conn = get conn, competence_path(conn, :edit, competence)
    assert html_response(conn, 200) =~ "Edit competence"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    competence = Repo.insert! %Competence{}
    conn = put conn, competence_path(conn, :update, competence), competence: @valid_attrs
    assert redirected_to(conn) == competence_path(conn, :show, competence)
    assert Repo.get_by(Competence, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    competence = Repo.insert! %Competence{}
    conn = put conn, competence_path(conn, :update, competence), competence: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit competence"
  end

  test "deletes chosen resource", %{conn: conn} do
    competence = Repo.insert! %Competence{}
    conn = delete conn, competence_path(conn, :delete, competence)
    assert redirected_to(conn) == competence_path(conn, :index)
    refute Repo.get(Competence, competence.id)
  end
end
