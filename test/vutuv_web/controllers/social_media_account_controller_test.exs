defmodule VutuvWeb.SocialMediaAccountControllerTest do
  use VutuvWeb.ConnCase

  import Vutuv.Factory
  import VutuvWeb.AuthTestHelpers

  alias Vutuv.SocialNetworks

  @create_attrs %{provider: "Facebook", value: "arrr"}

  setup %{conn: conn} do
    conn = conn |> bypass_through(VutuvWeb.Router, [:browser]) |> get("/")
    user = add_user("igor@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "read social media accounts" do
    test "lists a user's social media accounts", %{conn: conn, user: user} do
      social_media_account = insert(:social_media_account, %{user: user})
      conn = get(conn, Routes.user_social_media_account_path(conn, :index, user))
      assert html_response(conn, 200) =~ social_media_account.provider
    end

    test "shows a specific public social media account", %{conn: conn, user: user} do
      social_media_account = insert(:social_media_account, %{user: user})

      conn =
        get(conn, Routes.user_social_media_account_path(conn, :show, user, social_media_account))

      assert html_response(conn, 200) =~ social_media_account.provider
    end
  end

  describe "renders forms" do
    setup [:add_user_session]

    test "new social media account form", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_social_media_account_path(conn, :new, user))
      assert html_response(conn, 200) =~ "New social media account"
    end

    test "edit social media account form", %{conn: conn, user: user} do
      social_media_account = insert(:social_media_account, %{user: user})

      conn =
        get(conn, Routes.user_social_media_account_path(conn, :edit, user, social_media_account))

      assert html_response(conn, 200) =~ "Edit social media account"
    end
  end

  describe "write social media accounts" do
    setup [:add_user_session]

    test "create social media account with valid data", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_social_media_account_path(conn, :create, user),
          social_media_account: @create_attrs
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_social_media_account_path(conn, :show, user, id)
      assert get_flash(conn, :info) =~ "created successfully"
    end

    test "does not create social media account when data is invalid", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_social_media_account_path(conn, :create, user),
          social_media_account: %{"body" => ""}
        )

      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end

    test "update social media account with valid data", %{conn: conn, user: user} do
      social_media_account = insert(:social_media_account, %{user: user})

      conn =
        put(
          conn,
          Routes.user_social_media_account_path(conn, :update, user, social_media_account),
          social_media_account: %{"provider" => "Twitter"}
        )

      assert redirected_to(conn) ==
               Routes.user_social_media_account_path(conn, :show, user, social_media_account)

      assert get_flash(conn, :info) =~ "updated successfully"

      social_media_account =
        SocialNetworks.get_social_media_account!(user, social_media_account.id)

      assert social_media_account.provider =~ "Twitter"
    end

    test "does not update social media account when data is invalid", %{conn: conn, user: user} do
      social_media_account = insert(:social_media_account, %{user: user})

      conn =
        put(
          conn,
          Routes.user_social_media_account_path(conn, :update, user, social_media_account),
          social_media_account: %{"provider" => nil}
        )

      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end
  end

  describe "delete social media account" do
    setup [:add_user_session]

    test "can delete chosen social media account", %{conn: conn, user: user} do
      social_media_account = insert(:social_media_account, %{user: user})

      conn =
        delete(
          conn,
          Routes.user_social_media_account_path(conn, :delete, user, social_media_account)
        )

      assert redirected_to(conn) == Routes.user_social_media_account_path(conn, :index, user)
      assert get_flash(conn, :info) =~ "deleted successfully"

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
          Routes.user_social_media_account_path(conn, :delete, user, social_media_account)
        )
      end

      assert SocialNetworks.get_social_media_account!(other, social_media_account.id)
    end
  end

  defp add_user_session(%{conn: conn, user: user}) do
    conn = conn |> add_session(user) |> send_resp(:ok, "/")
    {:ok, %{conn: conn, user: user}}
  end
end
