defmodule Vutuv.ConnectionControllerTest do
  # use Vutuv.ConnCase
  #
  # alias Vutuv.Connection
  # @valid_attrs %{}
  # @invalid_attrs %{}
  #
  # test "lists all entries on index", %{conn: conn} do
  #   conn = get conn, connection_path(conn, :index)
  #   assert html_response(conn, 200) =~ "Listing connections"
  # end
  #
  # test "renders form for new resources", %{conn: conn} do
  #   conn = get conn, connection_path(conn, :new)
  #   assert html_response(conn, 200) =~ "New connection"
  # end
  #
  # test "creates resource and redirects when data is valid", %{conn: conn} do
  #   conn = post conn, connection_path(conn, :create), connection: @valid_attrs
  #   assert redirected_to(conn) == connection_path(conn, :index)
  #   assert Repo.get_by(Connection, @valid_attrs)
  # end
  #
  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, connection_path(conn, :create), connection: @invalid_attrs
  #   assert html_response(conn, 200) =~ "New connection"
  # end
  #
  # test "shows chosen resource", %{conn: conn} do
  #   connection = Repo.insert! %Connection{}
  #   conn = get conn, connection_path(conn, :show, connection)
  #   assert html_response(conn, 200) =~ "Show connection"
  # end
  #
  # test "renders page not found when id is nonexistent", %{conn: conn} do
  #   assert_error_sent 404, fn ->
  #     get conn, connection_path(conn, :show, -1)
  #   end
  # end
  #
  # test "renders form for editing chosen resource", %{conn: conn} do
  #   connection = Repo.insert! %Connection{}
  #   conn = get conn, connection_path(conn, :edit, connection)
  #   assert html_response(conn, 200) =~ "Edit connection"
  # end
  #
  # test "updates chosen resource and redirects when data is valid", %{conn: conn} do
  #   connection = Repo.insert! %Connection{}
  #   conn = put conn, connection_path(conn, :update, connection), connection: @valid_attrs
  #   assert redirected_to(conn) == connection_path(conn, :show, connection)
  #   assert Repo.get_by(Connection, @valid_attrs)
  # end
  #
  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   connection = Repo.insert! %Connection{}
  #   conn = put conn, connection_path(conn, :update, connection), connection: @invalid_attrs
  #   assert html_response(conn, 200) =~ "Edit connection"
  # end
  #
  # test "deletes chosen resource", %{conn: conn} do
  #   connection = Repo.insert! %Connection{}
  #   conn = delete conn, connection_path(conn, :delete, connection)
  #   assert redirected_to(conn) == connection_path(conn, :index)
  #   refute Repo.get(Connection, connection.id)
  # end
end
