defmodule Vutuv.JobPostingTagControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.JobPostingTag
  @valid_attrs %{job_posting_id: "some content", priority: "some content", tag_id: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, job_posting_tag_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing job posting tags"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, job_posting_tag_path(conn, :new)
    assert html_response(conn, 200) =~ "New job posting tag"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, job_posting_tag_path(conn, :create), job_posting_tag: @valid_attrs
    assert redirected_to(conn) == job_posting_tag_path(conn, :index)
    assert Repo.get_by(JobPostingTag, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, job_posting_tag_path(conn, :create), job_posting_tag: @invalid_attrs
    assert html_response(conn, 200) =~ "New job posting tag"
  end

  test "shows chosen resource", %{conn: conn} do
    job_posting_tag = Repo.insert! %JobPostingTag{}
    conn = get conn, job_posting_tag_path(conn, :show, job_posting_tag)
    assert html_response(conn, 200) =~ "Show job posting tag"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, job_posting_tag_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    job_posting_tag = Repo.insert! %JobPostingTag{}
    conn = get conn, job_posting_tag_path(conn, :edit, job_posting_tag)
    assert html_response(conn, 200) =~ "Edit job posting tag"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    job_posting_tag = Repo.insert! %JobPostingTag{}
    conn = put conn, job_posting_tag_path(conn, :update, job_posting_tag), job_posting_tag: @valid_attrs
    assert redirected_to(conn) == job_posting_tag_path(conn, :show, job_posting_tag)
    assert Repo.get_by(JobPostingTag, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    job_posting_tag = Repo.insert! %JobPostingTag{}
    conn = put conn, job_posting_tag_path(conn, :update, job_posting_tag), job_posting_tag: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit job posting tag"
  end

  test "deletes chosen resource", %{conn: conn} do
    job_posting_tag = Repo.insert! %JobPostingTag{}
    conn = delete conn, job_posting_tag_path(conn, :delete, job_posting_tag)
    assert redirected_to(conn) == job_posting_tag_path(conn, :index)
    refute Repo.get(JobPostingTag, job_posting_tag.id)
  end
end
