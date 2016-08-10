defmodule Vutuv.WorkExperienceControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.WorkExperience
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, work_experience_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing work experience"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, work_experience_path(conn, :new)
    assert html_response(conn, 200) =~ "New work experience"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, work_experience_path(conn, :create), work_experience: @valid_attrs
    assert redirected_to(conn) == work_experience_path(conn, :index)
    assert Repo.get_by(WorkExperience, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, work_experience_path(conn, :create), work_experience: @invalid_attrs
    assert html_response(conn, 200) =~ "New work experience"
  end

  test "shows chosen resource", %{conn: conn} do
    work_experience = Repo.insert! %WorkExperience{}
    conn = get conn, work_experience_path(conn, :show, work_experience)
    assert html_response(conn, 200) =~ "Show work experience"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, work_experience_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    work_experience = Repo.insert! %WorkExperience{}
    conn = get conn, work_experience_path(conn, :edit, work_experience)
    assert html_response(conn, 200) =~ "Edit work experience"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    work_experience = Repo.insert! %WorkExperience{}
    conn = put conn, work_experience_path(conn, :update, work_experience), work_experience: @valid_attrs
    assert redirected_to(conn) == work_experience_path(conn, :show, work_experience)
    assert Repo.get_by(WorkExperience, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    work_experience = Repo.insert! %WorkExperience{}
    conn = put conn, work_experience_path(conn, :update, work_experience), work_experience: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit work experience"
  end

  test "deletes chosen resource", %{conn: conn} do
    work_experience = Repo.insert! %WorkExperience{}
    conn = delete conn, work_experience_path(conn, :delete, work_experience)
    assert redirected_to(conn) == work_experience_path(conn, :index)
    refute Repo.get(WorkExperience, work_experience.id)
  end
end
