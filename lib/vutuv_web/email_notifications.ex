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
    addresses =
      Enum.group_by(Devices.list_subscribed_email_addresses(), &simplify_locale/1, & &1.value)

    do_send_emails(addresses, subject, body)
    Notifications.update_email_notification(email_notification, %{delivered: true})
  end

  defp simplify_locale(%{user: %{locale: locale}}) when locale in ["de", "de_DE", "de_CH"],
    do: "de"

  defp simplify_locale(_), do: "en"

  defp do_send_emails(%{"de" => german, "en" => english}, subject, body) do
    %{"de" => de_subject, "en" => en_subject} = get_translations(subject)
    %{"de" => de_body, "en" => en_body} = get_translations(body)
    Email.send_notification(german, de_subject, de_body)
    Email.send_notification(english, en_subject, en_body)
  end

  defp do_send_emails(%{"en" => addresses}, subject, body) do
    %{"en" => en_subject} = get_translations(subject)
    %{"en" => en_body} = get_translations(body)
    Email.send_notification(addresses, en_subject, en_body)
  end

  defp get_translations(text) do
    case Regex.split(~r/(\[de\]|\[en\])/, text, include_captures: true, trim: true) do
      [en] -> %{"de" => en, "en" => en}
      ["[de]", de, "[en]", en] -> %{"de" => de, "en" => en}
      ["[en]", en, "[de]", de] -> %{"de" => de, "en" => en}
    end
  end
end
