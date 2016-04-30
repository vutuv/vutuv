defmodule Vutuv.GroupControllerTest do
  # use Vutuv.ConnCase
  #
  # alias Vutuv.Group
  # @valid_attrs %{name: "some content"}
  # @invalid_attrs %{}
  #
  # test "lists all entries on index", %{conn: conn} do
  #   conn = get conn, group_path(conn, :index)
  #   assert html_response(conn, 200) =~ "Listing groups"
  # end
  #
  # test "renders form for new resources", %{conn: conn} do
  #   conn = get conn, group_path(conn, :new)
  #   assert html_response(conn, 200) =~ "New group"
  # end
  #
  # test "creates resource and redirects when data is valid", %{conn: conn} do
  #   conn = post conn, group_path(conn, :create), group: @valid_attrs
  #   assert redirected_to(conn) == group_path(conn, :index)
  #   assert Repo.get_by(Group, @valid_attrs)
  # end
  #
  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, group_path(conn, :create), group: @invalid_attrs
  #   assert html_response(conn, 200) =~ "New group"
  # end
  #
  # test "shows chosen resource", %{conn: conn} do
  #   group = Repo.insert! %Group{}
  #   conn = get conn, group_path(conn, :show, group)
  #   assert html_response(conn, 200) =~ "Show group"
  # end
  #
  # test "renders page not found when id is nonexistent", %{conn: conn} do
  #   assert_error_sent 404, fn ->
  #     get conn, group_path(conn, :show, -1)
  #   end
  # end
  #
  # test "renders form for editing chosen resource", %{conn: conn} do
  #   group = Repo.insert! %Group{}
  #   conn = get conn, group_path(conn, :edit, group)
  #   assert html_response(conn, 200) =~ "Edit group"
  # end
  #
  # test "updates chosen resource and redirects when data is valid", %{conn: conn} do
  #   group = Repo.insert! %Group{}
  #   conn = put conn, group_path(conn, :update, group), group: @valid_attrs
  #   assert redirected_to(conn) == group_path(conn, :show, group)
  #   assert Repo.get_by(Group, @valid_attrs)
  # end
  #
  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   group = Repo.insert! %Group{}
  #   conn = put conn, group_path(conn, :update, group), group: @invalid_attrs
  #   assert html_response(conn, 200) =~ "Edit group"
  # end
  #
  # test "deletes chosen resource", %{conn: conn} do
  #   group = Repo.insert! %Group{}
  #   conn = delete conn, group_path(conn, :delete, group)
  #   assert redirected_to(conn) == group_path(conn, :index)
  #   refute Repo.get(Group, group.id)
  # end
end
