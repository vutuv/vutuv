defmodule Vutuv.GroupControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.Group
  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, group_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    group = Repo.insert! %Group{}
    conn = get conn, group_path(conn, :show, group)
    assert json_response(conn, 200)["data"] == %{"id" => group.id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, group_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, group_path(conn, :create), group: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Group, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, group_path(conn, :create), group: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    group = Repo.insert! %Group{}
    conn = put conn, group_path(conn, :update, group), group: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Group, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    group = Repo.insert! %Group{}
    conn = put conn, group_path(conn, :update, group), group: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    group = Repo.insert! %Group{}
    conn = delete conn, group_path(conn, :delete, group)
    assert response(conn, 204)
    refute Repo.get(Group, group.id)
  end
end
