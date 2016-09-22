defmodule Vutuv.WorkExperienceControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.WorkExperience
  @valid_attrs %{}
  @invalid_attrs %{}

  # test "lists all entries on index", %{conn: conn} do
  #   conn = get conn, user_work_experience_path(conn, :index, conn.assigns[:current_user])
  #   assert html_response(conn, 200) =~ "Listing work experience"
  # end

  # test "renders form for new resources", %{conn: conn} do
  #   conn = get conn, user_work_experience_path(conn, :new, conn.assigns[:current_user])
  #   assert html_response(conn, 200) =~ "New work experience"
  # end

  # test "creates resource and redirects when data is valid", %{conn: conn} do
  #   conn = post conn, user_work_experience_path(conn, :create, conn.assigns[:current_user]), work_experience: @valid_attrs
  #   assert redirected_to(conn) == user_work_experience_path(conn, :index, conn.assigns[:current_user])
  #   assert Repo.get_by(WorkExperience, @valid_attrs)
  # end

  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, user_work_experience_path(conn, :create, conn.assigns[:current_user]), work_experience: @invalid_attrs
  #   assert html_response(conn, 200) =~ "New work experience"
  # end

  # test "shows chosen resource", %{conn: conn} do
  #   work_experience = Repo.insert! %WorkExperience{}
  #   conn = get conn, user_work_experience_path(conn, :show, conn.assigns[:current_user], work_experience)
  #   assert html_response(conn, 200) =~ "Show work experience"
  # end

  # test "renders page not found when id is nonexistent", %{conn: conn} do
  #   assert_error_sent 404, fn ->
  #     get conn, user_work_experience_path(conn, :show, conn.assigns[:current_user], -1)
  #   end
  # end

  # test "renders form for editing chosen resource", %{conn: conn} do
  #   work_experience = Repo.insert! %WorkExperience{}
  #   conn = get conn, user_work_experience_path(conn, :edit, conn.assigns[:current_user], work_experience)
  #   assert html_response(conn, 200) =~ "Edit work experience"
  # end

  # test "updates chosen resource and redirects when data is valid", %{conn: conn} do
  #   work_experience = Repo.insert! %WorkExperience{}
  #   conn = put conn, user_work_experience_path(conn, :update, conn.assigns[:current_user], work_experience), work_experience: @valid_attrs
  #   assert redirected_to(conn) == user_work_experience_path(conn, :show, conn.assigns[:current_user], work_experience)
  #   assert Repo.get_by(WorkExperience, @valid_attrs)
  # end

  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   work_experience = Repo.insert! %WorkExperience{}
  #   conn = put conn, user_work_experience_path(conn, :update, conn.assigns[:current_user], work_experience), work_experience: @invalid_attrs
  #   assert html_response(conn, 200) =~ "Edit work experience"
  # end

  # test "deletes chosen resource", %{conn: conn} do
  #   work_experience = Repo.insert! %WorkExperience{}
  #   conn = delete conn, user_work_experience_path(conn, :delete, conn.assigns[:current_user], work_experience)
  #   assert redirected_to(conn) == user_work_experience_path(conn, :index, conn.assigns[:current_user])
  #   refute Repo.get(WorkExperience, work_experience.id)
  # end
end
