defmodule Vutuv.VCardControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.User
  @valid_attrs %{}
  @invalid_attrs %{}

  # setup %{conn: conn} do
  #   {:ok, conn: put_req_header(conn, "accept", "application/json")}
  # end
  # test "gets v_card", %{conn: conn} do
  #   user = Repo.insert! %User{}
  #   conn = get conn, api_user_v_card_path(conn, :show, user)
  #   assert json_response(conn, 200)["data"] == %{"id" => user.id}
  # end

  # test "does not get vcard and instead throw error when id is nonexistent", %{conn: conn} do
  #   assert_error_sent 404, fn ->
  #     get conn, api_user_v_card_path(conn, :show, -1)
  #   end
  # end
end
