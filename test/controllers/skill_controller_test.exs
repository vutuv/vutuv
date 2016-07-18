defmodule Vutuv.SkillControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.Skill
  @valid_attrs %{description: "some content", downcase_name: "some content", name: "some content", slug: "some content", url: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, skill_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing skills"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, skill_path(conn, :new)
    assert html_response(conn, 200) =~ "New skill"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, skill_path(conn, :create), skill: @valid_attrs
    assert redirected_to(conn) == skill_path(conn, :index)
    assert Repo.get_by(Skill, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, skill_path(conn, :create), skill: @invalid_attrs
    assert html_response(conn, 200) =~ "New skill"
  end

  test "shows chosen resource", %{conn: conn} do
    skill = Repo.insert! %Skill{}
    conn = get conn, skill_path(conn, :show, skill)
    assert html_response(conn, 200) =~ "Show skill"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, skill_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    skill = Repo.insert! %Skill{}
    conn = get conn, skill_path(conn, :edit, skill)
    assert html_response(conn, 200) =~ "Edit skill"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    skill = Repo.insert! %Skill{}
    conn = put conn, skill_path(conn, :update, skill), skill: @valid_attrs
    assert redirected_to(conn) == skill_path(conn, :show, skill)
    assert Repo.get_by(Skill, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    skill = Repo.insert! %Skill{}
    conn = put conn, skill_path(conn, :update, skill), skill: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit skill"
  end

  test "deletes chosen resource", %{conn: conn} do
    skill = Repo.insert! %Skill{}
    conn = delete conn, skill_path(conn, :delete, skill)
    assert redirected_to(conn) == skill_path(conn, :index)
    refute Repo.get(Skill, skill.id)
  end
end
