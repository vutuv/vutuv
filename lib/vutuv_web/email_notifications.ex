defmodule VutuvWeb.EmailNotifications do
  @moduledoc """
  Module for handling email notifications to multiple users.
  """

  alias Vutuv.{Devices, Notifications}
  alias Vutuv.Notifications.EmailNotification
  alias VutuvWeb.Email

  @doc """
  Sends emails to all users and updates the email_notification delivered value.
  """
  def send_emails(%EmailNotification{body: body, subject: subject} = email_notification) do
    addresses = list_addresses()
    Email.notification(addresses, subject, body)
    Notifications.update_email_notification(email_notification, %{delivered: true})
  end

  defp list_addresses() do
    Enum.map(Devices.list_subscribed_email_addresses(), & &1.value)
  end
end
