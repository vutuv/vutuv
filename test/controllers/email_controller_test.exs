defmodule Vutuv.EmailControllerTest do
  # use Vutuv.ConnCase
  #
  # alias Vutuv.Email
  # @valid_attrs %{value: "john@example.com", user_id: "1"}
  # @invalid_attrs %{}
  #
  # test "lists all entries on index", %{conn: conn} do
  #   conn = get conn, email_path(conn, :index)
  #   assert html_response(conn, 200) =~ "Listing emails"
  # end
  #
  # test "renders form for new resources", %{conn: conn} do
  #   conn = get conn, email_path(conn, :new)
  #   assert html_response(conn, 200) =~ "New email"
  # end
  #
  # test "creates resource and redirects when data is valid", %{conn: conn} do
  #   conn = post conn, email_path(conn, :create), email: @valid_attrs
  #   assert redirected_to(conn) == email_path(conn, :index)
  #   assert Repo.get_by(Email, @valid_attrs)
  # end
  #
  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, email_path(conn, :create), email: @invalid_attrs
  #   assert html_response(conn, 200) =~ "New email"
  # end
  #
  # test "shows chosen resource", %{conn: conn} do
  #   email = Repo.insert! %Email{}
  #   conn = get conn, email_path(conn, :show, email)
  #   assert html_response(conn, 200) =~ "Show email"
  # end
  #
  # test "renders page not found when id is nonexistent", %{conn: conn} do
  #   assert_error_sent 404, fn ->
  #     get conn, email_path(conn, :show, -1)
  #   end
  # end
  #
  # test "renders form for editing chosen resource", %{conn: conn} do
  #   email = Repo.insert! %Email{}
  #   conn = get conn, email_path(conn, :edit, email)
  #   assert html_response(conn, 200) =~ "Edit email"
  # end
  #
  # test "updates chosen resource and redirects when data is valid", %{conn: conn} do
  #   email = Repo.insert! %Email{}
  #   conn = put conn, email_path(conn, :update, email), email: @valid_attrs
  #   assert redirected_to(conn) == email_path(conn, :show, email)
  #   assert Repo.get_by(Email, @valid_attrs)
  # end
  #
  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   email = Repo.insert! %Email{}
  #   conn = put conn, email_path(conn, :update, email), email: @invalid_attrs
  #   assert html_response(conn, 200) =~ "Edit email"
  # end
  #
  # test "deletes chosen resource", %{conn: conn} do
  #   email = Repo.insert! %Email{}
  #   conn = delete conn, email_path(conn, :delete, email)
  #   assert redirected_to(conn) == email_path(conn, :index)
  #   refute Repo.get(Email, email.id)
  # end
end
