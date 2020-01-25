defmodule VutuvWeb.EmailNotificationController do
  use VutuvWeb, :controller

  import VutuvWeb.Authorize

  alias Vutuv.{Accounts, Notifications}
  alias Vutuv.Notifications.EmailNotification
  alias VutuvWeb.EmailNotifications

  @dialyzer {:nowarn_function, new: 3}

  def action(%Plug.Conn{assigns: %{current_user: %{id: id} = current_user}} = conn, _) do
    if Accounts.user_is_admin?(id) do
      auth_action_slug(conn, __MODULE__)
    else
      unauthorized(conn, current_user)
    end
  end

  def action(conn, _), do: need_login(conn)

  def index(conn, _params, current_user) do
    email_notifications = Notifications.list_email_notifications(current_user)
    render(conn, "index.html", email_notifications: email_notifications)
  end

  def new(conn, _params, _current_user) do
    changeset = Notifications.change_email_notification(%EmailNotification{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"email_notification" => email_notification_params}, current_user) do
    case Notifications.create_email_notification(current_user, email_notification_params) do
      {:ok, email_notification} ->
        msg = send_emails(email_notification, email_notification_params, "created")

        conn
        |> put_flash(:info, gettext("Email notification %{msg} successfully.", msg: msg))
        |> redirect(
          to: Routes.user_email_notification_path(conn, :show, current_user, email_notification)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, current_user) do
    email_notification = Notifications.get_email_notification!(current_user, id)
    render(conn, "show.html", email_notification: email_notification, user: current_user)
  end

  def edit(conn, %{"id" => id}, current_user) do
    email_notification = Notifications.get_email_notification!(current_user, id)

    case email_notification.delivered do
      true ->
        conn
        |> put_flash(
          :error,
          gettext("You cannot edit this email notification as it has already been delivered.")
        )
        |> redirect(
          to: Routes.user_email_notification_path(conn, :show, current_user, email_notification)
        )

      _ ->
        changeset = Notifications.change_email_notification(email_notification)
        render(conn, "edit.html", email_notification: email_notification, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "email_notification" => email_notification_params}, current_user) do
    email_notification = Notifications.get_email_notification!(current_user, id)

    case Notifications.update_email_notification(email_notification, email_notification_params) do
      {:ok, email_notification} ->
        msg = send_emails(email_notification, email_notification_params, "updated")

        conn
        |> put_flash(:info, gettext("Email notification %{msg} successfully.", msg: msg))
        |> redirect(
          to: Routes.user_email_notification_path(conn, :show, current_user, email_notification)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", email_notification: email_notification, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    email_notification = Notifications.get_email_notification!(current_user, id)
    {:ok, _email_notification} = Notifications.delete_email_notification(email_notification)

    conn
    |> put_flash(:info, gettext("Email notification deleted successfully."))
    |> redirect(to: Routes.user_email_notification_path(conn, :index, current_user))
  end

  def send_emails(email_notification, %{"send_now" => "true"}, default) do
    EmailNotifications.send_emails(email_notification)
    "#{default} and sent"
  end

  def send_emails(_, _, default), do: default
end
