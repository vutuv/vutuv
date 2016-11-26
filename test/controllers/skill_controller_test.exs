defmodule Vutuv.SkillControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.Skill
  @valid_attrs %{"name" => "skill_name"}
  @invalid_attrs %{}

  # test "lists all entries on index", %{conn: conn} do
  #   conn = get conn, skill_path(conn, :index)
  #   assert html_response(conn, 200) =~ "skills"
  # end

  # test "shows chosen resource", %{conn: conn} do
  #   skill = Repo.insert! Skill.changeset(%Skill{}, %{"name" => "skill_name"})
  #   conn = get conn, skill_path(conn, :show, skill)
  #   assert html_response(conn, 200) =~ skill.name
  # end

  # test "renders page not found when id is nonexistent", %{conn: conn} do
  #   conn = get conn, skill_path(conn, :show, "skill_doesnt_exist")
  #   assert html_response(conn, :not_found)
  # end
end
