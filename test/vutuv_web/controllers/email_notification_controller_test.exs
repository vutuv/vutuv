defmodule VutuvWeb.EmailNotificationControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.{Accounts, Notifications}

  @create_attrs %{
    "subject" => "Welcome to Vutuv",
    "body" => "This is a blablabla ...",
    "send_now" => false
  }
  @invalid_attrs %{"body" => ""}

  setup %{conn: conn} do
    conn = conn |> bypass_through(VutuvWeb.Router, [:browser]) |> get("/")
    user = add_user("igor@example.com")
    user_credential = Accounts.get_user_credential!(%{"user_id" => user.id})
    {:ok, _user_credential} = Accounts.set_admin(user_credential, %{is_admin: true})
    conn = conn |> add_session(user) |> send_resp(:ok, "/")
    {:ok, %{conn: conn, user: user}}
  end

  describe "read email_notifications" do
    test "lists all email_notifications", %{conn: conn, user: user} do
      _email_notification = insert(:email_notification, %{owner: user})
      conn = get(conn, Routes.user_email_notification_path(conn, :index, user))
      assert html_response(conn, 200) =~ "Email notifications"
    end

    test "shows a single email_notifications", %{conn: conn, user: user} do
      email_notification = insert(:email_notification, %{owner: user})
      conn = get(conn, Routes.user_email_notification_path(conn, :show, user, email_notification))
      assert html_response(conn, 200) =~ "Email notification"
    end

    test "redirects unauthenticated user", %{user: user} do
      conn = build_conn()
      conn = get(conn, Routes.user_email_notification_path(conn, :index, user))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
      assert get_flash(conn, :error) =~ "need to log in"
    end

    test "redirects unauthorized user", %{conn: conn, user: user} do
      other = add_user("raymond@example.com")
      conn = get(conn, Routes.user_email_notification_path(conn, :index, other))
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      assert get_flash(conn, :error) =~ "not authorized"
    end

    test "redirects non-admin user", %{conn: conn, user: user} do
      user_credential = Accounts.get_user_credential!(%{"user_id" => user.id})
      {:ok, _user_credential} = Accounts.set_admin(user_credential, %{is_admin: false})
      conn = get(conn, Routes.user_email_notification_path(conn, :index, user))
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      assert get_flash(conn, :error) =~ "not authorized"
    end
  end

  describe "renders forms" do
    test "new email_notification form", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_email_notification_path(conn, :new, user))
      assert html_response(conn, 200) =~ "New email notification"
    end

    test "renders form for editing chosen email_notification", %{conn: conn, user: user} do
      email_notification = insert(:email_notification, %{owner: user})
      conn = get(conn, Routes.user_email_notification_path(conn, :edit, user, email_notification))
      assert html_response(conn, 200) =~ "Edit email notification"
    end

    test "redirects unauthenticated user", %{user: user} do
      conn = build_conn()
      conn = get(conn, Routes.user_email_notification_path(conn, :new, user))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
      assert get_flash(conn, :error) =~ "need to log in"
    end

    test "redirects non-admin user", %{conn: conn, user: user} do
      user_credential = Accounts.get_user_credential!(%{"user_id" => user.id})
      {:ok, _user_credential} = Accounts.set_admin(user_credential, %{is_admin: false})
      conn = get(conn, Routes.user_email_notification_path(conn, :new, user))
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      assert get_flash(conn, :error) =~ "not authorized"
    end
  end

  describe "write email_notification" do
    test "redirects to show when data is valid", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_email_notification_path(conn, :create, user),
          email_notification: @create_attrs
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_email_notification_path(conn, :show, user, id)

      conn = get(conn, Routes.user_email_notification_path(conn, :show, user, id))
      assert html_response(conn, 200) =~ "Email notification"
      assert get_flash(conn, :info) =~ "notification created successfully"
    end

    test "email is sent when send_now is set to true", %{conn: conn, user: user} do
      create_attrs = Map.merge(@create_attrs, %{"send_now" => true})

      conn =
        post(conn, Routes.user_email_notification_path(conn, :create, user),
          email_notification: create_attrs
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_email_notification_path(conn, :show, user, id)
      assert get_flash(conn, :info) =~ "notification created and sent successfully"
    end

    test "create renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_email_notification_path(conn, :create, user),
          email_notification: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "New email notification"
    end

    test "update email_notification with valid data", %{conn: conn, user: user} do
      email_notification = insert(:email_notification, %{owner: user})
      update_attrs = %{"body" => "Here are some updates to our service"}

      conn =
        put(conn, Routes.user_email_notification_path(conn, :update, user, email_notification),
          email_notification: update_attrs
        )

      assert redirected_to(conn) ==
               Routes.user_email_notification_path(conn, :show, user, email_notification)

      conn = get(conn, Routes.user_email_notification_path(conn, :show, user, email_notification))
      assert html_response(conn, 200) =~ "Here are some updates"
    end

    test "update renders errors when data is invalid", %{conn: conn, user: user} do
      email_notification = insert(:email_notification, %{owner: user})

      conn =
        put(conn, Routes.user_email_notification_path(conn, :update, user, email_notification),
          email_notification: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit email notification"
    end
  end

  describe "delete email_notification" do
    test "deletes chosen email_notification", %{conn: conn, user: user} do
      email_notification = insert(:email_notification, %{owner: user})

      conn =
        delete(conn, Routes.user_email_notification_path(conn, :delete, user, email_notification))

      assert redirected_to(conn) == Routes.user_email_notification_path(conn, :index, user)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_email_notification_path(conn, :show, user, email_notification))
      end
    end

    test "cannot delete another user's email_notification", %{conn: conn, user: user} do
      other = add_user("raymond@example.com")
      email_notification = insert(:email_notification, %{owner: other})

      assert_error_sent 404, fn ->
        delete(conn, Routes.user_email_notification_path(conn, :delete, user, email_notification))
      end

      assert Notifications.get_email_notification!(other, email_notification.id)
    end
  end
end
