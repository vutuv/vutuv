defmodule Vutuv.JobPostingControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.JobPosting
  @valid_attrs %{closed_on: "some content", description: "some content", location: "some content", open_on: "some content", prerequisites: "some content", recruiter_subscription_id: "some content", slug: "some content", title: "some content", user_id: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, job_posting_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing job postings"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, job_posting_path(conn, :new)
    assert html_response(conn, 200) =~ "Create a new job posting"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, job_posting_path(conn, :create), job_posting: @valid_attrs
    assert redirected_to(conn) == job_posting_path(conn, :index)
    assert Repo.get_by(JobPosting, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, job_posting_path(conn, :create), job_posting: @invalid_attrs
    assert html_response(conn, 200) =~ "Create a new job posting"
  end

  test "shows chosen resource", %{conn: conn} do
    job_posting = Repo.insert! %JobPosting{}
    conn = get conn, job_posting_path(conn, :show, job_posting)
    assert html_response(conn, 200) =~ "Show job posting"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, job_posting_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    job_posting = Repo.insert! %JobPosting{}
    conn = get conn, job_posting_path(conn, :edit, job_posting)
    assert html_response(conn, 200) =~ "Edit job posting"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    job_posting = Repo.insert! %JobPosting{}
    conn = put conn, job_posting_path(conn, :update, job_posting), job_posting: @valid_attrs
    assert redirected_to(conn) == job_posting_path(conn, :show, job_posting)
    assert Repo.get_by(JobPosting, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    job_posting = Repo.insert! %JobPosting{}
    conn = put conn, job_posting_path(conn, :update, job_posting), job_posting: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit job posting"
  end

  test "deletes chosen resource", %{conn: conn} do
    job_posting = Repo.insert! %JobPosting{}
    conn = delete conn, job_posting_path(conn, :delete, job_posting)
    assert redirected_to(conn) == job_posting_path(conn, :index)
    refute Repo.get(JobPosting, job_posting.id)
  end
end
