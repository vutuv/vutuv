defmodule Vutuv.RecruiterPackageControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.RecruiterPackage
  @valid_attrs %{auto_renewal: "some content", currency: "some content", description: "some content", duration_in_months: "some content", locale_id: "some content", max_job_postings: "some content", name: "some content", offer_begins: "some content", offer_ends: "some content", price: "some content", slug: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, admin_recruiter_package_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing recruiter packages"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, admin_recruiter_package_path(conn, :new)
    assert html_response(conn, 200) =~ "New recruiter package"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, admin_recruiter_package_path(conn, :create), recruiter_package: @valid_attrs
    assert redirected_to(conn) == admin_recruiter_package_path(conn, :index)
    assert Repo.get_by(RecruiterPackage, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, admin_recruiter_package_path(conn, :create), recruiter_package: @invalid_attrs
    assert html_response(conn, 200) =~ "New recruiter package"
  end

  test "shows chosen resource", %{conn: conn} do
    recruiter_package = Repo.insert! %RecruiterPackage{}
    conn = get conn, admin_recruiter_package_path(conn, :show, recruiter_package)
    assert html_response(conn, 200) =~ "Show recruiter package"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, admin_recruiter_package_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    recruiter_package = Repo.insert! %RecruiterPackage{}
    conn = get conn, admin_recruiter_package_path(conn, :edit, recruiter_package)
    assert html_response(conn, 200) =~ "Edit recruiter package"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    recruiter_package = Repo.insert! %RecruiterPackage{}
    conn = put conn, admin_recruiter_package_path(conn, :update, recruiter_package), recruiter_package: @valid_attrs
    assert redirected_to(conn) == admin_recruiter_package_path(conn, :show, recruiter_package)
    assert Repo.get_by(RecruiterPackage, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    recruiter_package = Repo.insert! %RecruiterPackage{}
    conn = put conn, admin_recruiter_package_path(conn, :update, recruiter_package), recruiter_package: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit recruiter package"
  end

  test "deletes chosen resource", %{conn: conn} do
    recruiter_package = Repo.insert! %RecruiterPackage{}
    conn = delete conn, admin_recruiter_package_path(conn, :delete, recruiter_package)
    assert redirected_to(conn) == admin_recruiter_package_path(conn, :index)
    refute Repo.get(RecruiterPackage, recruiter_package.id)
  end
end
