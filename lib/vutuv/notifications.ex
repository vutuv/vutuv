defmodule Vutuv.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto
  import Ecto.Query, warn: false

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  alias Vutuv.Notifications.EmailNotification
  alias Vutuv.{UserProfiles.User, Repo}

  @doc """
  Returns the list of email_notifications.
  """
  @spec list_email_notifications(User.t()) :: [EmailNotification.t()]
  def list_email_notifications(%User{} = user) do
    Repo.all(assoc(user, :email_notifications))
  end

  @doc """
  Gets a single email_notification.

  Raises `Ecto.NoResultsError` if the Email notification does not exist.
  """
  @spec get_email_notification!(User.t(), integer) :: EmailNotification.t() | no_return
  def get_email_notification!(%User{} = user, id) do
    Repo.get_by!(EmailNotification, id: id, owner_id: user.id)
  end

  @doc """
  Creates a email_notification.
  """
  @spec create_email_notification(User.t(), map) :: {:ok, EmailNotification.t()} | changeset_error
  def create_email_notification(%User{} = user, attrs \\ %{}) do
    user
    |> build_assoc(:email_notifications)
    |> EmailNotification.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a email_notification.
  """
  @spec update_email_notification(EmailNotification.t(), map) ::
          {:ok, EmailNotification.t()} | changeset_error
  def update_email_notification(%EmailNotification{delivered: true} = email_notification, _) do
    email_notification
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.add_error(:delivered, "cannot edit as it has already been delivered")
  end

  def update_email_notification(%EmailNotification{} = email_notification, attrs) do
    email_notification
    |> EmailNotification.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a EmailNotification.
  """
  @spec delete_email_notification(EmailNotification.t()) ::
          {:ok, EmailNotification.t()} | changeset_error
  def delete_email_notification(%EmailNotification{} = email_notification) do
    Repo.delete(email_notification)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking email_notification changes.
  """
  @spec change_email_notification(EmailNotification.t()) :: Ecto.Changeset.t()
  def change_email_notification(%EmailNotification{} = email_notification) do
    EmailNotification.changeset(email_notification, %{})
  end
end
