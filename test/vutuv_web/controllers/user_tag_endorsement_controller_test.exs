defmodule VutuvWeb.UserTagEndorsementControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.Tags

  setup %{conn: conn} do
    conn = conn |> bypass_through(VutuvWeb.Router, [:browser]) |> get("/")
    user = add_user("igor@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "write user_tag_endorsements" do
    setup [:add_user_session]

    test "create user_tag_endorsement with valid data", %{conn: conn, user: user} do
      user_tag = insert(:user_tag)
      attrs = %{user_tag_id: user_tag.id}

      conn =
        post(conn, Routes.user_tag_endorsement_path(conn, :create, user),
          user_tag_endorsement: attrs
        )

      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      assert get_flash(conn, :info) =~ "endorsed successfully"
    end
  end

  describe "delete user_tag_endorsement" do
    setup [:add_user_session]

    test "can delete chosen user_tag_endorsement", %{conn: conn, user: user} do
      user_tag = insert(:user_tag)

      {:ok, user_tag_endorsement} =
        Tags.create_user_tag_endorsement(user, %{"user_tag_id" => user_tag.id})

      conn =
        delete(conn, Routes.user_tag_endorsement_path(conn, :delete, user, user_tag_endorsement))

      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      assert get_flash(conn, :info) =~ "deleted successfully"
      assert_raise Ecto.NoResultsError, fn -> Tags.get_user_tag!(user, user_tag.id) end
    end
  end

  defp add_user_session(%{conn: conn, user: user}) do
    conn = conn |> add_session(user) |> send_resp(:ok, "/")
    {:ok, %{conn: conn, user: user}}
  end
end
