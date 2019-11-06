defmodule VutuvWeb.Api.SocialMediaAccountControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.SocialNetworks

  @create_attrs %{provider: "Facebook", value: "arrr"}

  setup %{conn: conn} do
    user = add_user("igor@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "read social media accounts" do
    test "lists a user's social media accounts", %{conn: conn, user: user} do
      social_media_account = insert(:social_media_account, %{user: user})
      conn = get(conn, Routes.api_user_social_media_account_path(conn, :index, user))
      assert [new_social_media_account] = json_response(conn, 200)["data"]
      assert new_social_media_account == single_response(social_media_account)
    end

    test "shows a specific public social media account", %{conn: conn, user: user} do
      social_media_account = insert(:social_media_account, %{user: user})

      conn =
        get(
          conn,
          Routes.api_user_social_media_account_path(conn, :show, user, social_media_account)
        )

      assert json_response(conn, 200)["data"] == single_response(social_media_account)
    end
  end

  describe "write social media accounts" do
    setup [:add_token_to_conn]

    test "create social media account with valid data", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.api_user_social_media_account_path(conn, :create, user),
          social_media_account: @create_attrs
        )

      assert json_response(conn, 201)["data"]["id"]
      [new_social_media_account] = SocialNetworks.list_social_media_accounts(user)
      assert new_social_media_account.provider == @create_attrs[:provider]
      assert new_social_media_account.value == @create_attrs[:value]
    end

    test "does not create social media account when data is invalid", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.api_user_social_media_account_path(conn, :create, user),
          social_media_account: %{"provider" => ""}
        )

      assert json_response(conn, 422)["errors"]["provider"] == ["can't be blank"]
    end

    test "update social media account with valid data", %{conn: conn, user: user} do
      social_media_account = insert(:social_media_account, %{user: user})

      conn =
        put(
          conn,
          Routes.api_user_social_media_account_path(conn, :update, user, social_media_account),
          social_media_account: %{"provider" => "Twitter"}
        )

      assert json_response(conn, 200)["data"]["id"]

      social_media_account =
        SocialNetworks.get_social_media_account!(user, social_media_account.id)

      assert social_media_account.provider =~ "Twitter"
    end

    test "does not update social media account when data is invalid", %{conn: conn, user: user} do
      social_media_account = insert(:social_media_account, %{user: user})

      conn =
        put(
          conn,
          Routes.api_user_social_media_account_path(conn, :update, user, social_media_account),
          social_media_account: %{"provider" => nil}
        )

      assert json_response(conn, 422)["errors"]["provider"] == ["can't be blank"]
    end
  end

  describe "delete social media account" do
    setup [:add_token_to_conn]

    test "can delete chosen social media account", %{conn: conn, user: user} do
      social_media_account = insert(:social_media_account, %{user: user})

      conn =
        delete(
          conn,
          Routes.api_user_social_media_account_path(conn, :delete, user, social_media_account)
        )

      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn ->
        SocialNetworks.get_social_media_account!(user, social_media_account.id)
      end
    end

    test "cannot delete another user's social media account", %{conn: conn, user: user} do
      other = add_user("raymond@example.com")
      social_media_account = insert(:social_media_account, %{user: other})

      assert_error_sent 404, fn ->
        delete(
          conn,
          Routes.api_user_social_media_account_path(conn, :delete, user, social_media_account)
        )
      end

      assert SocialNetworks.get_social_media_account!(other, social_media_account.id)
    end
  end

  defp single_response(social_media_account) do
    %{
      "id" => social_media_account.id,
      "user_id" => social_media_account.user_id,
      "provider" => social_media_account.provider,
      "value" => social_media_account.value
    }
  end
end
