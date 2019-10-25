defmodule Vutuv.NotificationsTest do
  use Vutuv.DataCase

  import Vutuv.Factory

  alias Vutuv.Notifications
  alias Vutuv.Notifications.EmailNotification

  @create_email_notification_attrs %{
    "subject" => "Important announcement",
    "body" => "We would like to announce ...",
    "delivered" => false
  }

  describe "read email_notifications data" do
    setup [:create_user]

    test "list_email_notifications/1 returns all email_notifications", %{user: user} do
      email_notification = insert(:email_notification, %{owner: user})
      _email_notification = insert(:email_notification)
      assert [email_notification_1] = Notifications.list_email_notifications(user)
      assert email_notification.id == email_notification_1.id
      assert email_notification_1.owner_id == user.id
    end

    test "get_email_notification!/2 returns the email_notification with given id", %{user: user} do
      email_notification = insert(:email_notification, %{owner: user})
      _email_notification = insert(:email_notification)

      assert email_notification =
               Notifications.get_email_notification!(user, email_notification.id)

      assert email_notification.owner_id == user.id
    end
  end

  describe "write email_notifications data" do
    setup [:create_user]

    test "create_email_notification/1 with valid data creates a email_notification", %{user: user} do
      assert {:ok, %EmailNotification{} = email_notification} =
               Notifications.create_email_notification(user, @create_email_notification_attrs)

      assert email_notification.subject =~ "Important announcement"
      assert email_notification.body =~ "We would like to announce ..."
      assert email_notification.delivered == false
      assert email_notification.owner_id == user.id
    end

    test "create_email_notification/1 with invalid data returns error changeset", %{user: user} do
      invalid_attrs = %{body: ""}

      assert {:error, %Ecto.Changeset{}} =
               Notifications.create_email_notification(user, invalid_attrs)
    end

    test "update_email_notification/2 with valid data updates the email_notification" do
      email_notification = insert(:email_notification)
      update_attrs = %{"body" => "Nothing to announce", "delivered" => true}

      assert {:ok, %EmailNotification{} = email_notification} =
               Notifications.update_email_notification(email_notification, update_attrs)

      assert email_notification.body =~ "Nothing to announce"
      assert email_notification.delivered == true
    end

    test "update_email_notification/2 with invalid data returns error changeset", %{user: user} do
      email_notification = insert(:email_notification, %{owner: user})
      invalid_attrs = %{body: ""}

      assert {:error, %Ecto.Changeset{}} =
               Notifications.update_email_notification(email_notification, invalid_attrs)

      assert email_notification_1 =
               Notifications.get_email_notification!(user, email_notification.id)

      assert email_notification.id == email_notification_1.id
    end
  end

  describe "delete email_notifications data" do
    setup [:create_user]

    test "delete_email_notification/1 deletes the email_notification", %{user: user} do
      email_notification = insert(:email_notification, %{owner: user})

      assert {:ok, %EmailNotification{}} =
               Notifications.delete_email_notification(email_notification)

      assert_raise Ecto.NoResultsError, fn ->
        Notifications.get_email_notification!(user, email_notification.id)
      end
    end
  end

  defp create_user(_) do
    user = insert(:user)
    {:ok, %{user: user}}
  end
end
