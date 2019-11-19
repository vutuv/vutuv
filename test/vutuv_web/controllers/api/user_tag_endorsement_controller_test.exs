defmodule VutuvWeb.Api.UserTagEndorsementControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.Tags

  setup %{conn: conn} do
    user = add_user("igor@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "write user_tag_endorsements" do
    setup [:add_token_to_conn]

    test "create user_tag_endorsement with valid data", %{conn: conn, user: user} do
      user_tag = insert(:user_tag)
      attrs = %{user_tag_id: user_tag.id}

      conn =
        post(conn, Routes.api_user_tag_endorsement_path(conn, :create, user),
          user_tag_endorsement: attrs
        )

      assert %{
               "data" => %{
                 "id" => endorsement_id,
                 "user_id" => user_id,
                 "user_tag_id" => user_tag_id
               }
             } = json_response(conn, 201)

      assert Tags.get_user_tag_endorsement!(user, endorsement_id)
      assert user_id == user.id
      assert user_tag_id == user_tag.id
    end
  end

  describe "delete user_tag_endorsement" do
    setup [:add_token_to_conn]

    test "can delete chosen user_tag_endorsement", %{conn: conn, user: user} do
      user_tag = insert(:user_tag)

      {:ok, user_tag_endorsement} =
        Tags.create_user_tag_endorsement(user, %{"user_tag_id" => user_tag.id})

      conn =
        delete(
          conn,
          Routes.api_user_tag_endorsement_path(conn, :delete, user, user_tag_endorsement)
        )

      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn ->
        Tags.get_user_tag_endorsement!(user, user_tag.id)
      end
    end
  end
end
