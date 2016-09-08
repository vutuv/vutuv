defmodule Vutuv.VCardControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.VCard
  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, v_card_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    v_card = Repo.insert! %VCard{}
    conn = get conn, v_card_path(conn, :show, v_card)
    assert json_response(conn, 200)["data"] == %{"id" => v_card.id}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, v_card_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, v_card_path(conn, :create), v_card: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(VCard, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, v_card_path(conn, :create), v_card: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    v_card = Repo.insert! %VCard{}
    conn = put conn, v_card_path(conn, :update, v_card), v_card: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(VCard, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    v_card = Repo.insert! %VCard{}
    conn = put conn, v_card_path(conn, :update, v_card), v_card: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    v_card = Repo.insert! %VCard{}
    conn = delete conn, v_card_path(conn, :delete, v_card)
    assert response(conn, 204)
    refute Repo.get(VCard, v_card.id)
  end
end
